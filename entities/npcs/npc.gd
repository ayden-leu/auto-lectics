extends Node3D
class_name NPC

signal options_available
signal finished_dialogue

@onready var dialogueBoxScene:Resource = preload(Globals.SCENES.DialogueBox)
@onready var dialogueBoxAnchor:Marker3D = $DialogueBoxAnchor
var dialogueBox:DialogueBox = null
var isTalking:bool = false

var idleDialogueID:int = 0

var normalDialogue:Array[Dictionary] = [
	{
		"id": 0,
		"initial": "who are you.  why are you interacting with me...",
		"mode": "normal",
		"options": [
			{
				"text": "your shirt looks cool",
				"type": "good",
				"spawnDelay": 3.0,
				"nextID": 1,
			},
			{
				"text": "where are you library?",
				"type": "bad",
				"spawnDelay": 0.5,
				"nextID": 2
			},
			{
				"text": "oh sorry, i thought you were someone else",
				"type": "neutral",
				"spawnDelay": 1.0,
				"nextID": 3
			}
		]
	},
	{
		"id": 1,
		"initial": "oh thanks",
		"mode": "normal",
		"options": []
	},
	{
		"id": 2,
		"initial": "what? weirdo",
		"mode": "normal",
		"options": []
	},
	{
		"id": 3,
		"initial": "ah no problem",
		"mode": "normal",
		"options": []
	}
]

var hecticDialogue:Array[Dictionary] = [
	{
		"id": 0,
		"initial": "you got 5 seconds to respond pal",
		"mode": "hectic",
		"options": [
			{
				"text": "uhhhhhhhhh yes",
				"type": "good",
				"spawnDelay": 1.0,
				"nextID": 1,
			},
			{
				"text": "florida",
				"type": "bad",
				"spawnDelay": 0.25,
				"nextID": 2
			},
			{
				"text": "nice weather we're having",
				"type": "neutral",
				"spawnDelay": 0.5,
				"nextID": 3
			}
		]
	},
	{
		"id": 1,
		"initial": "correct!",
		"mode": "normal",
		"options": []
	},
	{
		"id": 2,
		"initial": "wrong answer",
		"mode": "normal",
		"options": []
	},
	{
		"id": 3,
		"initial": "yea i guess",
		"mode": "normal",
		"options": []
	},
	{
		"id": 10,  # TODO:  make these dummy entries use strings.  make fail dialogue id "failure"
		"initial": "you failed",
		"mode": "normal",
		"options": []
	}
]
var currentDialogue:Array[Dictionary]


var delayStartShowingOptions:float = 1.5

func _ready() -> void:
	# testing stuff
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var test:int = randi_range(0, 1)
	if test == 0:
		loadMyDialogueTree(normalDialogue)
	else:
		loadMyDialogueTree(hecticDialogue)

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
	
	await get_tree().create_timer(delayStartShowingOptions).timeout
	
	if entryToLoad.options.size() == 0:
		dialogueBox.kill()
		isTalking = false
		finished_dialogue.emit()
		return

	dialogueBox.createOptions()

func _on_interaction() -> void:
	if isTalking:
		return
	
	isTalking = true
	spawnDialogue()
	loadNextDialogue(idleDialogueID)

func _on_dialogue_box_new_options_spawned() -> void:
	options_available.emit()

#func _on_dialogue_box_all_options_spawned() -> void:
	#options_available.emit()
