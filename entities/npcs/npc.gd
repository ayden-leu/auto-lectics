extends Node3D
class_name NPC

@onready var dialogueBoxScene:Resource = preload(Globals.SCENES.DialogueBox)
@onready var dialogueBoxAnchor:Marker3D = $DialogueBoxAnchor
var dialogueBox:DialogueBox = null
var isTalking:bool = false

var idleDialogueIndex:int = 0

var dialogue:Array[Dictionary] = [
	{
		"id": 0,
		"initial": "who are you.  why are you interacting with me...",
		"mode": "normal",
		"options": [
			{
				"text": "your shirt looks cool",
				"type": "good",
				"spawnDelay": 2.5,
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

var delayStartShowingOptions:float = 1.5

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func spawnDialogue() -> void:
	if dialogueBox != null:
		return
	
	dialogueBox = dialogueBoxScene.instantiate()
	dialogueBox.connect("update_me", loadNextDialogue)
	dialogueBoxAnchor.add_child(dialogueBox)

# TODO:  update to match new dialogue format
func loadMyDialogueTree(tree:Array) -> void:
	dialogue = tree

func loadData(dialogueEntry:Dictionary) -> void:
	dialogueBox.mode = dialogueEntry.mode
	dialogueBox.text = dialogueEntry.initial
	dialogueBox.loadOptionData(dialogueEntry.options)
	dialogueBox.prepare()

# TODO:  update to match new dialogue format
func loadNextDialogue(id:int) -> void:
	loadData(dialogue[id])
	
	await get_tree().create_timer(delayStartShowingOptions).timeout
	
	if dialogue[id].options.size() == 0:
		dialogueBox.kill()
		isTalking = false
		return

	dialogueBox.createOptions()

func _onInteraction() -> void:
	if isTalking:
		return
	
	isTalking = true
	spawnDialogue()
	loadNextDialogue(idleDialogueIndex)
