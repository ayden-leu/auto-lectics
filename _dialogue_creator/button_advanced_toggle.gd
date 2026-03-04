extends CheckBox

@export var fields:Array[Container]

func _ready() -> void:
	for field in fields:
		field.visible = false

func _on_toggled(toggled_on: bool) -> void:
	for field in fields:
		field.visible = toggled_on
