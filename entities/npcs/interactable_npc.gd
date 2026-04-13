@icon("uid://b105kdcrwpi0r")
@tool
extends NPC
class_name InteractableNPC
## The base class of all Interactable NPCs in the game.  Interactable NPCs allow the player to interact with them and initiate a dialogue event.

## Emitted when a dialogue entry is fully displayed.
signal dialogue_all_visible
## Emitted when a dialogue option is spawned.
signal option_available
## Emitted when all dialogue options have been spawned.
signal all_options_available
## Emitted when the dialogue tree reaches an end.
signal finished_dialogue

## Attach methods for the [DialogueBox]
enum ATTACH_METHOD {
	FOLLOW,  ## When spawned, the [DialogueBox] will be in the same relative position and rotation as this [InteractableNPC] all of the time.  If the [InteractableNPC] moves left, the DialogueBox will move left.  If the the [member dialogueBoxAnchor] is right above the [InteractableNPC] and the [InteractableNPC] flips upside down, the [DialogueBox] will be physically below the [InteractableNPC] and upside down.
	STAY  ## When spawned, the [DialogueBox] will take the position and rotation of the [member dialogueBoxAnchor] at that moment and stay there.  If the [InteractableNPC] moves or rotates after this moment, the [DialogueBox] will stay in place.
}

## The hitbox of this Interactable NPC.
@export var hitbox:Area3D
## Tells the game where to spawn a dialogue box when a player interacts with the Interactable NPC.
@export var dialogueBoxAnchor:Marker3D
## How the [DialogueBox] should act after beind spawned.
@export var dialogueBoxAttachMethod:ATTACH_METHOD
## All dialogues belonging to this Interactable NPC will be under "dialogue_objects/[NPC name]"
@export var initialDialogueID:String = ""
## If this Interactable NPC should only respond to interactions once.
@export var talkOnlyOnce:bool = true
## Whether this [InteractableNPC] looks at the player while the dialogue event is happening.
@export var lookAtInteractorWhileTalking:bool = false

const _dialogueBoxScene:Resource = preload(Globals.SCENES.DialogueBox)#
const _dialogueConsoleScene: Resource = preload(Globals.SCENES.DialogueConsoleUI)


## The hitbox's collision shape.  Gets set when the node is ready.
var hitboxShapes:Array[CollisionShape3D]
## Holds a reference to this Interactable NPC's dialogue box scene.
var dialogueBox:DialogueBox = null
var dialogueConsole: DialogueConsoleUI = null
## Single-use boolean to determine if the dialogue box's signals have been connected to functions yet.
var connectedDialogueBoxSignals:bool = false
var connectedDialogueConsoleSignals: bool = false
## Is true when their dialogue box is visible.
var isTalking: bool = false
## Keeps track of which dialogue object to reference at the moment.
var currentDialogueID: String = ""
## Keeps track of if the player has interacted with this Interactable NPC.  If true, this NPC can no longer be talked to.
var wasTalkedTo: bool = false
## Tracks who is interacting with this NPC; curently can only be the player
var currentInteractor:Node3D
## Tracks whether the NPC should be patrolling
var shouldPatrol:bool
## Array that stores previous dialogue history
var dialogueHistory: Array[String] = []

func _ready() -> void:
	# Makes sure the code after this is only ran in-game
	if Engine.is_editor_hint():
		return
	super()
	shouldPatrol = patrolEnabled
	
	currentDialogueID = initialDialogueID
	hitboxShapes = getHitboxShapes()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	super(delta)
	if lookAtInteractorWhileTalking and currentInteractor and isTalking:
		lookAtPosition = currentInteractor.global_position

## Gets the hitbox's collision shapes.
func getHitboxShapes() -> Array[CollisionShape3D]:
	var children:Array[Node] = hitbox.get_children()
	var shapes:Array[CollisionShape3D] = []
	
	for child in children:
		if child is CollisionShape3D:
			shapes.push_back(child)
	return shapes
		
## Creates the dialogue console scene. Only one can exist at a time.
func spawnDialogueConsole() -> void:
	if dialogueConsole != null:
		return
	
	dialogueConsole = _dialogueConsoleScene.instantiate()
	dialogueConsole.set_npc_id(myName)
	
	# This UI should be on-screen, so add it somewhere in the active scene tree
	get_tree().current_scene.add_child(dialogueConsole)

## Connects the dialogue box's signals to functions. Only needs to be ran once.
func connectDialogueConsoleSignals() -> void:
	if connectedDialogueConsoleSignals:
		return
	connectedDialogueConsoleSignals = true

	dialogueConsole.option_chosen.connect(loadNextDialogue)
	dialogueConsole.request_back.connect(_on_console_request_back)
	dialogueConsole.new_option_available.connect(_on_dialogue_box_new_option_spawned)
	dialogueConsole.all_options_available.connect(_on_dialogue_box_all_options_available)
	dialogueConsole.all_dialogue_text_visible.connect(_on_dialogue_box_all_dialogue_text_visible)

func disconnectDialogueConsoleSignals() -> void:
	if not connectedDialogueConsoleSignals:
		return
	connectedDialogueConsoleSignals = false
	
	dialogueConsole.option_chosen.disconnect(loadNextDialogue)
	dialogueConsole.request_back.disconnect(_on_console_request_back)
	dialogueConsole.new_option_available.disconnect(_on_dialogue_box_new_option_spawned)
	dialogueConsole.all_options_available.disconnect(_on_dialogue_box_all_options_available)
	dialogueConsole.all_dialogue_text_visible.disconnect(_on_dialogue_box_all_dialogue_text_visible)

## Loads the data of a dialogue object into the dialogue box. Make sure currentDialogueID is set to the dialogue you want to load before running.
func loadDialogueData(dialogueEntry: Dictionary) -> void:
	dialogueConsole.realOwner = self
	dialogueConsole.currentDialogueID = currentDialogueID
	dialogueConsole.mode = dialogueEntry.mode
	
	if dialogueEntry.mode == "hectic":
		dialogueConsole.hecticFailureDialogueID = dialogueEntry.get("nextOnHecticFailureID", "")
		dialogueConsole.delayBtwnWriteDialogueAndOptions = 0.25
	
	dialogueConsole.textWriteSpeed = dialogueEntry.writeSpeedCustom
	dialogueConsole.sfxEventsToLoad = dialogueEntry.sfx
	dialogueConsole.show_dialogue_data(dialogueEntry)
	dialogueConsole.loadOptionData(dialogueEntry.options)
	dialogueConsole.prepare()

## Loads the next dialogue to display.
func loadNextDialogue(nextDialogueID: String, addToHistory: bool = true) -> void:
	if nextDialogueID == "" and isTalking:
		endDialogue()
		return
	
	currentDialogueID = nextDialogueID
	
	if addToHistory:
		dialogueHistory.push_back(currentDialogueID)
	
	var dialogue: Dictionary = Globals.getDialogueNode(myName, currentDialogueID)
	loadDialogueData(dialogue)
	dialogueConsole.start()


func _on_console_request_back() -> void:
	if dialogueHistory.size() <= 1:
		return
	
	dialogueHistory.pop_back()
	var previous_id: String = dialogueHistory.back()
	loadNextDialogue(previous_id, false)


## Ends the dialogue interaction.
func endDialogue() -> void:
	disconnectDialogueConsoleSignals()
	if dialogueConsole != null:
		dialogueConsole.kill()
		dialogueConsole = null
	
	if currentInteractor and currentInteractor.has_method("set_input_frozen"):
		currentInteractor.set_input_frozen(false)
	Globals.inputHandler.unlock_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	isTalking = false
	currentInteractor = null
	if shouldPatrol:
		patrolEnabled = true
	if talkOnlyOnce:
		wasTalkedTo = true

	finished_dialogue.emit()

## Enables the Interactable NPC.  This will make it so the player can interact with this Interactable NPC.
func enable() -> void:
	hitbox.monitorable = true
	for shape in hitboxShapes:
		shape.set_deferred("disabled", false)
	
## Disables the Interactable NPC.  This will make it so the player cannot interact with this Interactable NPC.
func disable() -> void:
	hitbox.monitorable = false
	for shape in hitboxShapes:
		shape.set_deferred("disabled", true)

## Resets the Interactable NPC to their default state.
func reset() -> void:
	if isTalking:
		endDialogue()
	currentDialogueID = initialDialogueID
	wasTalkedTo = false


## Handles flow of what to do when this [InteractableNPC] is interacted with.
func _on_interaction(interactor: Node3D = null) -> void:
	if wasTalkedTo or isTalking:
		return
	
	var currentRotation: Vector3 = rotation
	if lookAtInteractorWhileTalking and interactor:
		look_at(Vector3(
			interactor.global_position.x,
			global_position.y,
			interactor.global_position.z
		))
		lookAtPosition = interactor.global_position
	
	isTalking = true
	patrolEnabled = false
	currentInteractor = interactor
	dialogueHistory.clear()
	
	if currentInteractor and currentInteractor.has_method("set_input_frozen"):
		currentInteractor.set_input_frozen(true)
		Globals.inputHandler.lock_mouse_to_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	spawnDialogueConsole()
	connectDialogueConsoleSignals()
	loadNextDialogue(initialDialogueID)
	
	rotation = currentRotation


## Emits the "option_available" signal.
func _on_dialogue_box_new_option_spawned() -> void:
	option_available.emit()


## Emits the "all_options_available" signal.
func _on_dialogue_box_all_options_available() -> void:
	all_options_available.emit()

## Emits the "dialogue_all_visible" signal.
func _on_dialogue_box_all_dialogue_text_visible() -> void:
	dialogue_all_visible.emit()

## Handles logic for when the HUD overlay fades in.  Currently, it disables and resets the Interactable NPC.
func _on_hud_overlay_faded_in() -> void:
	disable()
	reset()

## Handles logic for when the HUD overlay fades in.  Currently, it enables the Interactable NPC.
func _on_hud_overlay_faded_out() -> void:
	enable()



# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
		
	if not hitbox:
		warnings.push_back("This NPC doesn't have a hitbox assigned yet. This is needed to allow the player to interact with them. A hitbox is an Area3D node.")
	elif hitbox.collision_layer != 4:
		warnings.push_back("The hitbox's collision layer should only have square #3/Bit 2/the Interactable NPC layer enabled.")
	
	if initialDialogueID == "":
		warnings.push_back("The initial dialogue ID is not set.")
	
	if not dialogueBoxAnchor:
		warnings.push_back("A marker for the dialogue box has not been set yet.")
	
	var inheritedWarnings:PackedStringArray = super()
	inheritedWarnings.append_array(warnings)
	
	return inheritedWarnings
