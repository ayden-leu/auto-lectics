extends CheckBox
class_name DC_SectionToggle
## A [CheckBox] who's purpose is to hide/show various nodes when pressed.
## It's a [CheckBox] and not a [CheckButton] because the icon is on the left.

## Emitted when the [member fields] get hidden/shown.
signal resize

## The nodes to hide/show when the button is pressed.
@export var fields:Array[Container]

func _ready() -> void:
	toggle_mode = true
	_on_toggled(false)

func _on_toggled(toggled_on: bool) -> void:
	for field in fields:
		field.visible = toggled_on
	resize.emit()
