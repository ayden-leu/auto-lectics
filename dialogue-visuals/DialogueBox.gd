extends Node3D
class_name DialogueBox

@onready var myLabel:Label3D = $DialogueLabel
#var optionScenePath:String = "res://dialogue-visuals/dialogue-option.tscn"

var optionData:Array = []

func _ready() -> void:
	visible = false
	
func _process(_delta: float) -> void:
	pass


func initialize() -> void:
	visible = true
	
	await get_tree().create_timer(1.0).timeout
	

func setDialogueText(text:String) -> void:
	myLabel.text = text

func loadOptionData(options:Array) -> void:
	optionData = options

func spawnOption() -> void:
	pass
