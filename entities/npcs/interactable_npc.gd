@icon("uid://b105kdcrwpi0r")
@tool
extends NPC
class_name InteractableNPC
## The base class of all Interactable NPCs in the game.  Interactable NPCs allow the player to interact with them and initiate a dialogue event.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when a dialogue entry is fully displayed.
signal dialogue_all_visible()
## Emitted when a dialogue option is spawned.
signal option_available()
## Emitted when all dialogue options have been spawned.
signal all_options_available()
## Emitted when the dialogue tree reaches an end.
signal finished_dialogue()

# ------------------------------------------------
# enums
# ------------------------------------------------
## @deprecated
## Attach methods for the [DialogueBox].
enum AttachMethod {
	FOLLOW,  ## When spawned, the [DialogueBox] will be in the same relative position and rotation as this [InteractableNPC] all of the time.  If the [InteractableNPC] moves left, the DialogueBox will move left.  If the the [member _dialogueBoxAnchor] is right above the [InteractableNPC] and the [InteractableNPC] flips upside down, the [DialogueBox] will be physically below the [InteractableNPC] and upside down.
	STAY  ## When spawned, the [DialogueBox] will take the position and rotation of the [member _dialogueBoxAnchor] at that moment and stay there.  If the [InteractableNPC] moves or rotates after this moment, the [DialogueBox] will stay in place.
}

# ------------------------------------------------
# constants
# ------------------------------------------------
## @deprecated
## [b]Internal-use only.[/b]  A reference to the [DialogueBox] scene.
const _DIALOGUE_BOX_SCENE:Resource = preload(Globals.SCENES.DialogueBox)

const _dialogueConsoleScene: Resource = preload(Globals.SCENES.DialogueConsoleUI)

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The hitbox of this Interactable NPC.  Used to allow players to interact with
## this [InteractableNPC].
@export var _hitbox:Area3D
## @deprecated
## Tells the game where to spawn a [DialogueBox] when a player interacts with the Interactable NPC.
@export var _dialogueBoxAnchor:Marker3D
## @deprecated
## How the [DialogueBox] should act after beind spawned.
@export var _dialogueBoxAttachMethod:AttachMethod
## If this Interactable NPC should only respond to interactions once.
@export var _talkOnlyOnce:bool = true
## All dialogues belonging to this Interactable NPC will be under "dialogue_objects/[NPC name]"
@export var initialDialogueID:String = ""
## Whether this [InteractableNPC] looks at the player while the dialogue event is happening.
@export var lookAtInteractorWhileTalking:bool = false




# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Is true when their dialogue box is visible.
var isTalking: bool = false
## Keeps track of if the player has interacted with this Interactable NPC.  If true, this NPC can no longer be talked to.
var wasTalkedTo: bool = false


## Array that stores previous dialogue history
var dialogueHistory: Array[String] = []

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  The hitbox's collision shape.  Gets set when the node is ready.
var _hitboxShapes:Array[CollisionShape3D]
## @deprecated
## [b]Internal-use only.[/b]  Holds a reference to this Interactable NPC's dialogue box scene.
var _dialogueBox:DialogueBox = null
## @deprecated
## [b]Internal-use only.[/b]  Single-use boolean to determine if the dialogue box's signals have been connected to functions yet.
var _connectedDialogueBoxSignals:bool = false
## [b]Internal-use only.[/b]  Keeps track of which dialogue object to reference at the moment.
var _currentDialogueID: String = ""
## [b]Internal-use only.[/b]  Tracks who is interacting with this NPC; curently can only be the player
var _currentInteractor:Node3D
## [b]Internal-use only.[/b]  Tracks whether the NPC should be patrolling.
## Mainly used to restore patrol state after finishing a dialogue interaction.
var _shouldPatrol:bool


var dialogueConsole: DialogueConsoleUI = null
## Single-use boolean to determine if the dialogue console's signals have been connected to functions yet.
var connectedDialogueConsoleSignals: bool = false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	# Makes sure the code after this is only ran in-game
	if Engine.is_editor_hint():
		return
	
	super()
	_shouldPatrol = patrolEnabled
	_currentDialogueID = initialDialogueID
	_hitboxShapes = _getHitboxShapes()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	super(delta)
	if lookAtInteractorWhileTalking and _currentInteractor and isTalking:
		lookAtPosition = _currentInteractor.global_position

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Enables the Interactable NPC.  This will make it so the player can interact with this Interactable NPC.
func enable() -> void:
	_hitbox.monitorable = true
	for shape in _hitboxShapes:
		shape.set_deferred("disabled", false)
	
## Disables the Interactable NPC.  This will make it so the player cannot interact with this Interactable NPC.
func disable() -> void:
	_hitbox.monitorable = false
	for shape in _hitboxShapes:
		shape.set_deferred("disabled", true)

## Resets the Interactable NPC to their default state.
func reset() -> void:
	if isTalking:
		_endDialogue()
	_currentDialogueID = initialDialogueID
	wasTalkedTo = false

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Gets the [member hitbox]'s collision shapes.
func _getHitboxShapes() -> Array[CollisionShape3D]:
	var children:Array[Node] = _hitbox.get_children()
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

	dialogueConsole.option_chosen.connect(loadNextDialogueConsole)
	dialogueConsole.open_gate.connect(openGate)
	dialogueConsole.request_back.connect(_on_console_request_back)
	dialogueConsole.new_option_available.connect(_on_dialogue_box_new_option_spawned)
	dialogueConsole.all_options_available.connect(_on_dialogue_box_all_options_available)
	dialogueConsole.all_dialogue_text_visible.connect(_on_dialogue_box_all_dialogue_text_visible)

func disconnectDialogueConsoleSignals() -> void:
	if not connectedDialogueConsoleSignals:
		return
	connectedDialogueConsoleSignals = false
	
	dialogueConsole.option_chosen.disconnect(loadNextDialogueConsole)
	dialogueConsole.open_gate.disconnect(openGate)
	dialogueConsole.request_back.disconnect(_on_console_request_back)
	dialogueConsole.new_option_available.disconnect(_on_dialogue_box_new_option_spawned)
	dialogueConsole.all_options_available.disconnect(_on_dialogue_box_all_options_available)
	dialogueConsole.all_dialogue_text_visible.disconnect(_on_dialogue_box_all_dialogue_text_visible)

## Loads the data of a dialogue object into the dialogue console. Make sure currentDialogueID is set to the dialogue you want to load before running.
func loadDialogueConsoleData(dialogueEntry: Dictionary) -> void:
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
## [b]Internal-use only.[/b]  Creates a [DialogueBox]. Only one can exist at a time.
func _spawnDialogueBox() -> void:
	if _dialogueBox != null:
		return
	
	_dialogueBox = _DIALOGUE_BOX_SCENE.instantiate()
	if(_dialogueBoxAttachMethod == AttachMethod.FOLLOW):
		_dialogueBoxAnchor.add_child(_dialogueBox)
		
		# undo the scaling being inherited from this InteractableNPC
		_dialogueBox.scale += Vector3.ONE - scale 
	elif(_dialogueBoxAttachMethod == AttachMethod.STAY):
		get_parent().add_child(_dialogueBox)
		_dialogueBox.global_position = _dialogueBoxAnchor.global_position
		_dialogueBox.global_rotation = _dialogueBoxAnchor.global_rotation

## [b]Internal-use only.[/b]  Connects the [member dialogueBox] signals to functions.
## Only needs to be ran once.
func _connectDialogueBoxSignals() -> void:
	if _connectedDialogueBoxSignals:
		return
	_connectedDialogueBoxSignals = true
	
	_dialogueBox.update_me.connect(_loadNextDialogue)
	_dialogueBox.new_option_available.connect(_on_dialogue_box_new_option_spawned)
	_dialogueBox.all_options_available.connect(_on_dialogue_box_all_options_available)
	_dialogueBox.all_dialogue_text_visible.connect(_on_dialogue_box_all_dialogue_text_visible)

## [b]Internal-use only.[/b]  Disconnects the [member dialogueBox] signals to functions.
func _disconnectDialogueBoxSignals() -> void:
	if not _connectedDialogueBoxSignals:
		return
	_connectedDialogueBoxSignals = false

	_dialogueBox.update_me.disconnect(_loadNextDialogue)
	_dialogueBox.new_option_available.disconnect(_on_dialogue_box_new_option_spawned)
	_dialogueBox.all_options_available.disconnect(_on_dialogue_box_all_options_available)
	_dialogueBox.all_dialogue_text_visible.disconnect(_on_dialogue_box_all_dialogue_text_visible)

## @deprecated
## [b]Internal-use only.[/b]  Loads the data of a dialogue object into the dialogue box.
## Make sure [member _currentDialogueID] is set to the dialogue you want to load before running.
func _loadDialogueData(dialogueEntry:Dictionary) -> void:
	_dialogueBox.realOwner = self
	_dialogueBox._currentDialogueID = _currentDialogueID
	_dialogueBox.mode = dialogueEntry.mode
	if dialogueEntry.mode == "hectic":
		_dialogueBox.hecticFailureDialogueID = dialogueEntry.nextOnHecticFailureID
		_dialogueBox.delayBtwnWriteDialogueAndOptions = 0.25  # arbitrary
	_dialogueBox.text = dialogueEntry.text
	_dialogueBox.textWriteSpeed = dialogueEntry.writeSpeedCustom
	_dialogueBox.loadSfx(dialogueEntry.sfx)
	_dialogueBox.loadOptionData(dialogueEntry.options)
	_dialogueBox.prepare()

	
## Loads the next dialogue to display.
func loadNextDialogueConsole(nextDialogueID: String, addToHistory: bool = true) -> void:
	if nextDialogueID == "" and isTalking:
		_endDialogue()
		return
	
	currentDialogueID = nextDialogueID
	
	if addToHistory:
		dialogueHistory.push_back(currentDialogueID)
	
	var dialogue: Dictionary = Globals.getDialogueNode(myName, currentDialogueID)
	loadDialogueConsoleData(dialogue)
	dialogueConsole.start()


func _on_console_request_back() -> void:
	if dialogueHistory.size() <= 1:
		dialogueConsole.add_player_text("[no recorded history in log]")
		return
	
	dialogueHistory.pop_back()
	dialogueConsole.add_player_text("back")
	var previous_id: String = dialogueHistory.back()
	loadNextDialogueConsole(previous_id, false)
	return

## [b]Internal-use only.[/b]  Loads the next dialogue to display.
func _loadNextDialogue(nextDialogueID: String) -> void:
	#print("\nloading dialogue: [", nextDialogueID, "]")
	if nextDialogueID == "" and isTalking:
		_endDialogue()
		return
	
	_currentDialogueID = nextDialogueID
	
	var dialogue:Dictionary = Globals.getDialogueNode(myName, _currentDialogueID)
	#print("dialogue data: ", dialogue)
	_loadDialogueData(dialogue)
	_dialogueBox.start()

## [b]Internal-use only.[/b]  Ends the dialogue interaction.
func _endDialogue() -> void:
	_disconnectDialogueBoxSignals()
	if _dialogueBox != null:
		_dialogueBox.kill()
		_dialogueBox = null
	
	disconnectDialogueConsoleSignals()
	if dialogueConsole != null:
		dialogueConsole.kill()
		dialogueConsole = null
	
	if currentInteractor and currentInteractor.has_method("set_input_frozen"):
		currentInteractor.set_input_frozen(false)
	Globals.inputHandler.unlock_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	isTalking = false
	_currentInteractor = null
	if _shouldPatrol:
		patrolEnabled = true
	if _talkOnlyOnce:
		wasTalkedTo = true

	finished_dialogue.emit()
# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## Handles flow of what to do when this [InteractableNPC] is interacted with.
func _on_interaction(interactor: Node3D = null) -> void:
	if wasTalkedTo or isTalking:
		return
	
	# rotate to face player immediately to properly spawn dialogue box
	# is a hacky work around to spawn the [DialogueBox] in the correct position.
	var currentRotation:Vector3 = rotation
	if lookAtInteractorWhileTalking and interactor:
		look_at(Vector3(
			interactor.global_position.x,
			global_position.y,
			interactor.global_position.z
		))
		lookAtPosition = interactor.global_position
	
	isTalking = true
	patrolEnabled = false
	_currentInteractor = interactor
	
	dialogueHistory.clear()
	if currentInteractor and currentInteractor.has_method("set_input_frozen"):
		currentInteractor.set_input_frozen(true)
		Globals.inputHandler.lock_mouse_to_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	#_spawnDialogueBox()
	#_connectDialogueBoxSignals()
	#_loadNextDialogue(initialDialogueID)

	spawnDialogueConsole()
	connectDialogueConsoleSignals()
	loadNextDialogueConsole(initialDialogueID)
	
	# restore rotation from before hacky work around
	rotation = currentRotation

## Emits [signal option_available].
func _on_dialogue_box_new_option_spawned() -> void:
	option_available.emit()

## Emits [all_options_available].
func _on_dialogue_box_all_options_available() -> void:
	all_options_available.emit()

## Emits [dialogue_all_visible].
func _on_dialogue_box_all_dialogue_text_visible() -> void:
	dialogue_all_visible.emit()

## Handles logic for when the HUD overlay fades in.  Currently, it disables and resets the Interactable NPC.
func _on_hud_overlay_faded_in() -> void:
	disable()
	reset()

## Handles logic for when the HUD overlay fades in.  Currently, it enables the Interactable NPC.
func _on_hud_overlay_faded_out() -> void:
	enable()

func openGate():
	print("open gate!")
	if $gateNode:
		$gateNode.open_gate()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
		
	if not _hitbox:
		warnings.push_back("This NPC doesn't have a hitbox assigned yet. This is needed to allow the player to interact with them. A hitbox is an Area3D node.")
	elif _hitbox.collision_layer != 4:
		warnings.push_back("The hitbox's collision layer should only have square #3/Bit 2/the Interactable NPC layer enabled.")
	
	if initialDialogueID == "":
		warnings.push_back("The initial dialogue ID is not set.")
	
	if not _dialogueBoxAnchor:
		warnings.push_back("A marker for the dialogue box has not been set yet.")
	
	var inheritedWarnings:PackedStringArray = super()
	inheritedWarnings.append_array(warnings)
	
	return inheritedWarnings
