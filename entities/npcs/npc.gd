extends Node3D
class_name NPC

signal options_available
signal finished_dialogue

@onready var dialogueBoxScene: Resource = preload(Globals.SCENES.DialogueBox)
@onready var dialogueBoxAnchor: Marker3D = $DialogueBoxAnchor

## Valid dialogue entries can be found in `dialogue_objects`
@export var initialDialogueID: String = "Dialogue1a"
@export var myName:String = "NPC_Test"

var dialogueBox: DialogueBox = null
var isTalking: bool = false
var currentDialogueID: String = ""
var delayStartShowingOptions: float = 1.0
var loader := DialogueLoader.new()

func _ready() -> void:
	currentDialogueID = initialDialogueID

func _process(_delta: float) -> void:
	pass

func spawnDialogue() -> void:
	if dialogueBox != null:
		return
	
	dialogueBox = dialogueBoxScene.instantiate()
	dialogueBox.connect("update_me", loadNextDialogue)
	dialogueBox.connect("new_option_available", _on_dialogue_box_new_options_spawned)
	#dialogueBox.connect("all_options_spawned", _on_dialogue_box_all_options_spawned)
	dialogueBoxAnchor.add_child(dialogueBox)

# TODO:  update to match new dialogue format
func loadMyDialogueTree(tree:Array) -> void:
	currentDialogue = tree

func loadData(dialogueEntry:Dictionary) -> void:
	dialogueBox.currentDialogueID = dialogueEntry.id
	dialogueBox.mode = dialogueEntry.mode
	dialogueBox.text = dialogueEntry.initial
	dialogueBox.loadOptionData(dialogueEntry.options)
	dialogueBox.prepare()

# TODO:  update to match new dialogue format
func loadNextDialogue(id:int) -> void:
	var entryToLoad:Dictionary
	for entry in currentDialogue:
		if entry.id == id:
			entryToLoad = entry
			break
	loadData(entryToLoad)
	
	# TODO:  verify this note
	# IMPORTANT CHANGE:
	# DialogueBox should emit "update_me" with the option's nextID (String),
	# not an array index. If it currently emits an int, update DialogueBox (see below).
	dialogueBox.connect("update_me", loadNextDialogue)

	dialogueBoxAnchor.add_child(dialogueBox)

func loadData(dialogueData: Dictionary) -> void:
	dialogueBox.text = dialogueData.text
	dialogueBox.optionData = dialogueData.options

func loadNextDialogue(nextDialogueID: String) -> void:
	# TODO:  maybe remove this part
	if nextDialogueID == "":
		_end_dialogue()
		return

	currentDialogueID = nextDialogueID
	var dialogue := Globals.loadDialogueNode(myName, currentDialogueID)
	# this never ran
	#if dlg.is_empty():
		#_end_dialogue()
		#return
	loadData(dialogue)

	await get_tree().create_timer(delayStartShowingOptions).timeout
 
	if dialogue.options.size() == 0:
		_end_dialogue()
		return

	dialogueBox.createOptions()

func _end_dialogue() -> void:
	if dialogueBox != null:
		dialogueBox.kill()
		dialogueBox = null
	isTalking = false

func _onInteraction() -> void:
	if isTalking:
		return

	isTalking = true
	spawnDialogue()

	# Start at initialDialogueID
	loadNextDialogue(initialDialogueID)

func _on_dialogue_box_new_options_spawned() -> void:
	options_available.emit()

#func _on_dialogue_box_all_options_spawned() -> void:
	#options_available.emit()
