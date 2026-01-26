extends Node3D

@onready var label:Label3D = $TextLabel

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	pass
	
func setText(text:String) -> void:
	label.text = text
