extends Node3D

var counter:int = 0
var mode:String = "normal"
var canChooseOption:bool = false

# TODO:  update dummy dialogue to fit new format
# TODO:  add new fields:
#			hectic mode duration
#			nextID for when you fail hectic mode

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

var dialogueToLoad:Array[Dictionary] = normalDialogue

func _ready() -> void:
	updateLabel("Mode: ", mode)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_1"):
		match counter:
			0:
				$NPC_Test.loadMyDialogueTree(dialogueToLoad)
				$NPC_Test._on_interaction()
				counter = 1
			1:
				if not canChooseOption:
					return
				canChooseOption = true
					
				$NPC_Test.dialogueBox.loadedOptions[0]._onInteraction()
				counter = 2
	
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


func _on_npc_test_finished_dialogue() -> void:
	counter = 0

func _on_npc_test_options_available() -> void:
	canChooseOption = true
