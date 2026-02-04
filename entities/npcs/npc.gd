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

var delayStartShowingOptions:float = 1.0

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
	
func loadData(dialogueEntry:Dictionary) -> void:
	dialogueBox.text = dialogueEntry.initial
	dialogueBox.loadOptionData(dialogueEntry.options)

func loadNextDialogue(data) -> void:
	loadData(dialogue[data])
	
	await get_tree().create_timer(delayStartShowingOptions).timeout
	
	if dialogue[data].options.size() == 0:
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
