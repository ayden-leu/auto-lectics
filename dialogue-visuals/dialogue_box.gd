extends Node3D

@onready var label : Label3D = $DialogueLabel

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	pass


func setDialogueText(text:String) -> void:
	label.text = text

func spawnOption() -> void:
	pass
