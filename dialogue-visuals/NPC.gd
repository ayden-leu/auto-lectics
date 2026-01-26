extends Node3D

@onready var dialogueBoxScene:Resource = preload("res://dialogue-visuals/DialogueBox.tscn")
var dialogueBox:DialogueBox = null


var dialogue:Dictionary = {
	"initial": "who are you.  why are you interacting with me...",
	"options": [
		{
			"text": "your shirt looks cool",
			"type": "good"
		},
		{
			"text": "where are you library?",
			"type": "bad"
		},
		{
			"text": "oh sorry, i thought you were someone else",
			"type": "neutral"
		}
	]
}


func _ready() -> void:
	spawnDialogue()

func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_accept"):
		loadData(dialogue)
		dialogueBox.initialize()

func spawnDialogue() -> void:
	if dialogueBox != null:
		return
	
	dialogueBox = dialogueBoxScene.instantiate()
	add_child(dialogueBox)
	dialogueBox.position = Vector3(0, 1.214, 1.941)
	dialogueBox.rotation_degrees = Vector3(0.0, 16.8, 0.0)
	
func loadData(dialogueEntry:Dictionary) -> void:
	dialogueBox.setDialogueText(dialogueEntry.initial)
	dialogueBox.loadOptionData(dialogueEntry.options)
