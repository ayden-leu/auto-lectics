@icon("uid://bmn0gum6ccama")
@tool
extends Node3D
## The base class of all NPCs in the game.
class_name NPC

# TODO:  verify/add signal emitions for all signals

## Emitted when a dialogue entry is fully displayed.
signal dialogue_all_visible
## Emitted when a dialogue option is spawned.
signal option_available
## Emitted when all dialogue options have been spawned.
signal all_options_available
## Emitted when the dialogue tree reaches an end.
signal finished_dialogue

## The main model of the NPC.
@export var model:Node3D
## Tells the game where to spawn a dialogue box when a player interacts with the NPC. If the NPC moves or rotates, the dialogue box will move and rotate with them.
@export var dialogueBoxAnchor:Marker3D
## The name of the NPC.
@export var myName:String = ""
## All dialogues belonging to this NPC will be under "dialogue_objects/[NPC name]"
@export var initialDialogueID:String = ""

## Holds a reference to the dialogue box resource.
const dialogueBoxScene:Resource = preload(Globals.SCENES.DialogueBox)

## Holds a reference to this NPC's dialogue box scene.
var dialogueBox:DialogueBox = null
## If this is the first time spawning the dialogue box for an interaction.
var firstTimeSpawningDialogue:bool = true
## Single-use boolean to determine if the dialogue box's signals have been connected to functions yet.
var connectedDialogueBoxSignals:bool = false
## Is true when their dialogue box is visible.
var isTalking: bool = false
## Keeps track of which dialogue object to reference at the moment.
var currentDialogueID: String = ""
## Hardcoded delay between the dialogue being fully displayed, and when the dialogue options can begin spawning.
var delayStartShowingOptions: float = 1.0

func _ready() -> void:
	# Makes sure the code after this is only ran in-game
	if Engine.is_editor_hint():
		return
	
	currentDialogueID = initialDialogueID

func _process(_delta: float) -> void:
	pass

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
	
	dialogueBox.connect("update_me", loadNextDialogue)
	dialogueBox.connect("new_option_available", _on_dialogue_box_new_option_spawned)
	dialogueBox.connect("all_options_available", _on_dialogue_box_all_options_available)
	dialogueBox.connect("all_dialogue_text_visible", _on_dialogue_box_all_dialogue_text_visible)

## Loads the data of a dialogue object into the dialogue box. Make sure currentDialogueID is set to the dialogue you want to load before running.
func loadDialogueData(dialogueEntry:Dictionary) -> void:
	dialogueBox.realOwner = self
	dialogueBox.currentDialogueID = currentDialogueID
	dialogueBox.mode = dialogueEntry.mode
	if dialogueEntry.mode == "hectic":	
		dialogueBox.hecticFailureDialogueID = dialogueEntry.nextOnHecticFailureID
	dialogueBox.text = dialogueEntry.text
	dialogueBox.sfxEventsToLoad = dialogueEntry.sfx
	dialogueBox.loadOptionData(dialogueEntry.options)
	dialogueBox.prepare()

## Loads the next dialogue to display.
func loadNextDialogue(nextDialogueID: String) -> void:
	#print("\nloading dialogue: ", nextDialogueID)
	
	if nextDialogueID == "" and isTalking:
		endDialogue()
		return
	currentDialogueID = nextDialogueID
	
	var dialogue:Dictionary = Globals.getDialogueNode(myName, currentDialogueID)
	#print("dialogue data: ", dialogue)
	loadDialogueData(dialogue)
	dialogueBox.start(firstTimeSpawningDialogue)
	if firstTimeSpawningDialogue:
		firstTimeSpawningDialogue = false
	
	# TODO: remove this section.  move logic to dialogue_box.start()
	await get_tree().create_timer(delayStartShowingOptions).timeout

	if dialogue.options.size() == 0 and isTalking:
		endDialogue()
		return

	dialogueBox.createOptions()

## Ends the dialogue interaction.
func endDialogue() -> void:
	#print("ending")
	
	dialogueBox.kill()
	dialogueBox = null
	isTalking = false
	connectedDialogueBoxSignals = false
	firstTimeSpawningDialogue = true
	finished_dialogue.emit()

## Handles flow of what to do when a player interacts with this NPC.
func _on_interaction() -> void:
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

func _on_dialogue_box_all_dialogue_text_visible() -> void:
	dialogue_all_visible.emit()


# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	var hitbox:Area3D = null
	for child in get_children():
		if child is Area3D:
			hitbox = child
	
	if not model:
		warnings.push_back("This NPC doesn't have a model.")
	
	if initialDialogueID == "":
		warnings.push_back("The initial dialogue ID is not set.")
	
	if myName == "":
		warnings.push_back("This NPC doesn't have a name yet.")
	
	if hitbox == null:
		warnings.push_back("This NPC doesn't have a hitbox yet. This is needed to allow the player to interact with them. A hitbox is an Area3D node.")
	elif hitbox.collision_layer != 4:
		warnings.push_back("The hitbox's collision layer should only have square #3/Bit 2/the NPC layer enabled.")
	
	if self != get_tree().edited_scene_root:
		if not dialogueBoxAnchor:
			warnings.push_back("A marker for the dialogue box has not been set yet.")
		elif dialogueBoxAnchor.get_parent() == self:
			warnings.push_back("Making the marker for the dialogue box a child of the NPC will make the dialogue box move with it if you move the NPC's root node (i.e the one with a custom icon). If this is not desired and you must move the NPC's root node, you can:\n1) Make the marker a not a child of the NPC or its children.\n2) Add a Node (the white hollow circle) as a child to the NPC, then add the marker as a child of the Node.\nThis must be done within the level scene, as doing it within the NPC scene will cause the marker to be at the level's origin (0,0,0).")
	
	return warnings
