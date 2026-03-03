extends CheckBox

signal resize

@export var fields:Array[Container]

func _ready() -> void:
	_on_toggled(false)

func _on_toggled(toggled_on: bool) -> void:
	for field in fields:
		field.visible = toggled_on
	resize.emit()
