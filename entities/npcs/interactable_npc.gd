@icon("uid://b105kdcrwpi0r")
@tool
extends NPC
class_name InteractableNPC
## The base class of all Interactable NPCs in the game.  Interactable NPCs allow the player to interact with them and initiate a dialogue event.

# TODO:  make configuration for how the DialogueBox should stick to the dialogueBoxAnchor
#			option 1:  stick to it always (make it a child, current implementation)
#			option 2:  use its position on the frame it spawns (don't make it a child)

## Emitted when a dialogue entry is fully displayed.
signal dialogue_all_visible
## Emitted when a dialogue option is spawned.
signal option_available
## Emitted when all dialogue options have been spawned.
signal all_options_available
## Emitted when the dialogue tree reaches an end.
signal finished_dialogue

## The hitbox of this Interactable NPC.
@export var hitbox:Area3D
## Tells the game where to spawn a dialogue box when a player interacts with the Interactable NPC.
@export var dialogueBoxAnchor:Marker3D
## All dialogues belonging to this Interactable NPC will be under "dialogue_objects/[NPC name]"
@export var initialDialogueID:String = ""
## If this Interactable NPC should only respond to interactions once.
@export var talkOnlyOnce:bool = true

## Holds a reference to the diaslogue box resource.
const dialogueBoxScene:Resource = preload(Globals.SCENES.DialogueBox)

## The hitbox's collision shape.  Gets set when the node is ready.
var hitboxShapes:Array[CollisionShape3D]
## Holds a reference to this Interactable NPC's dialogue box scene.
var dialogueBox:DialogueBox = null
## Single-use boolean to determine if the dialogue box's signals have been connected to functions yet.
var connectedDialogueBoxSignals:bool = false
## Is true when their dialogue box is visible.
var isTalking: bool = false
## Keeps track of which dialogue object to reference at the moment.
var currentDialogueID: String = ""
## Keeps track of if the player has interacted with this Interactable NPC.  If true, this NPC can no longer be talked to.
var wasTalkedTo: bool = false

func _ready() -> void:
	# Makes sure the code after this is only ran in-game
	if Engine.is_editor_hint():
		return
	
	currentDialogueID = initialDialogueID
	hitboxShapes = getHitboxShapes()

## Gets the hitbox's collision shapes.
func getHitboxShapes() -> Array[CollisionShape3D]:
	var children:Array[Node] = hitbox.get_children()
	var shapes:Array[CollisionShape3D] = []
	
	for child in children:
		if child is CollisionShape3D:
			shapes.push_back(child)
	return shapes
		
## Creates the dialogue box scene. Only one can exist at a time.
func spawnDialogueBox() -> void:
	if dialogueBox != null:
		return
	
	dialogueBox = dialogueBoxScene.instantiate()
	dialogueBoxAnchor.add_child(dialogueBox)

## Connects the dialogue box's signals to functions. Only needs to be ran once.
func connectDialogueBoxSignals() -> void:
	if connectedDialogueBoxSignals:
		return
	connectedDialogueBoxSignals = true
	
	dialogueBox.update_me.connect(loadNextDialogue)
	dialogueBox.new_option_available.connect(_on_dialogue_box_new_option_spawned)
	dialogueBox.all_options_available.connect(_on_dialogue_box_all_options_available)
	dialogueBox.all_dialogue_text_visible.connect(_on_dialogue_box_all_dialogue_text_visible)

func disconnectDialogueBoxSignals() -> void:
	if not connectedDialogueBoxSignals:
		return
	connectedDialogueBoxSignals = false

	dialogueBox.update_me.disconnect(loadNextDialogue)
	dialogueBox.new_option_available.disconnect(_on_dialogue_box_new_option_spawned)
	dialogueBox.all_options_available.disconnect(_on_dialogue_box_all_options_available)
	dialogueBox.all_dialogue_text_visible.disconnect(_on_dialogue_box_all_dialogue_text_visible)

## Loads the data of a dialogue object into the dialogue box. Make sure currentDialogueID is set to the dialogue you want to load before running.
func loadDialogueData(dialogueEntry:Dictionary) -> void:
	dialogueBox.realOwner = self
	dialogueBox.currentDialogueID = currentDialogueID
	dialogueBox.mode = dialogueEntry.mode
	if dialogueEntry.mode == "hectic":	
		dialogueBox.hecticFailureDialogueID = dialogueEntry.nextOnHecticFailureID
		dialogueBox.delayBtwnWriteDialogueAndOptions = 0.25  # arbitrary
	dialogueBox.text = dialogueEntry.text
	dialogueBox.textWriteSpeed = dialogueEntry.writeSpeedCustom
	dialogueBox.sfxEventsToLoad = dialogueEntry.sfx
	dialogueBox.loadOptionData(dialogueEntry.options)
	dialogueBox.prepare()

## Loads the next dialogue to display.
func loadNextDialogue(nextDialogueID: String) -> void:
	#print("\nloading dialogue: [", nextDialogueID, "]")
	if nextDialogueID == "" and isTalking:
		endDialogue()
		return
	currentDialogueID = nextDialogueID
	
	var dialogue:Dictionary = Globals.getDialogueNode(myName, currentDialogueID)
	#print("dialogue data: ", dialogue)
	loadDialogueData(dialogue)
	dialogueBox.start()

## Ends the dialogue interaction.
func endDialogue() -> void:
	disconnectDialogueBoxSignals()
	if dialogueBox != null:
		dialogueBox.kill()
		dialogueBox = null
	
	isTalking = false
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


## Handles flow of what to do when a player interacts with this Interactable NPC.
func _on_interaction() -> void:
	if wasTalkedTo:
		return
	
	if isTalking:
		return
	isTalking = true
	
	spawnDialogueBox()
	connectDialogueBoxSignals()
	loadNextDialogue(initialDialogueID)

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
		warnings.push_back("This Interactable NPC doesn't have a hitbox assigned yet. This is needed to allow the player to interact with them. A hitbox is an Area3D node.")
	elif hitbox.collision_layer != 4:
		warnings.push_back("The hitbox's collision layer should only have square #3/Bit 2/the Interactable NPC layer enabled.")
	
	if initialDialogueID == "":
		warnings.push_back("The initial dialogue ID is not set.")
	
	if self != get_tree().edited_scene_root:
		if not dialogueBoxAnchor:
			warnings.push_back("A marker for the dialogue box has not been set yet.")
		elif dialogueBoxAnchor.get_parent() == self:
			warnings.push_back("Making the marker for the dialogue box a child of the Interactable NPC will make the dialogue box move with it if you move the Interactable NPC's root node (i.e the one with a custom icon). If this is not desired and you must move the Interactable NPC's root node, you can:\n1) Make the marker a not a child of the Interactable NPC or its children.\n2) Add a Node (the white hollow circle) as a child to the NPC, then add the marker as a child of the Node.\nThis must be done within the level scene, as doing it within the Interactable NPC scene will cause the marker to be at the level's origin (0,0,0).")
	
	return warnings
