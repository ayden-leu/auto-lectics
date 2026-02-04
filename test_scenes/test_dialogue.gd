extends Node3D

var counter:int = 0
var mode:String = "normal"

# TODO:  update dummy dialogue to fit new format

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
		"options": []
	},
	{
		"id": 2,
		"initial": "what? weirdo",
		"options": []
	},
	{
		"id": 3,
		"initial": "ah no problem",
		"options": []
	}
]

var hecticDialogue:Array[Dictionary] = [
	{
		"id": 0,
		"initial": "you got 3 seconds to respond pal",
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
		"options": []
	},
	{
		"id": 2,
		"initial": "no",
		"options": []
	},
	{
		"id": 3,
		"initial": "yea i guess",
		"options": []
	}
]

var dialogueToLoad:Array[Dictionary] = normalDialogue

func _ready() -> void:
	updateLabel("Mode: ", mode)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_1"):
		match counter:
			0:
				$NPC_Test.loadMyDialogueTree(dialogueToLoad)
				$NPC_Test._onInteraction()
				counter = 1
			1:
				$NPC_Test.dialogueBox.loadedOptions[0]._onInteraction()
				counter = 0
	
	if Input.is_action_just_pressed("debug_2"):
		match mode:
			"normal":
				mode = "hectic"
				dialogueToLoad = hecticDialogue
			"hectic":
				mode = "normal"
				dialogueToLoad = normalDialogue
		updateLabel("Mode: ", mode)

func updateLabel(prefix:String = "", content:String = "", suffix:String = "") -> void:
	$Control/Label.text = prefix + content + suffix
