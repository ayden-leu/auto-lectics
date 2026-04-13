extends Panel
class_name DialogueConsoleOptionWindow

signal option_selected

@onready var id_label: Label = $IDLabel
@onready var option_label: Label = $OptionLabel

var _dragging := false
var _drag_offset := Vector2.ZERO


func set_option_data(id_num: int, text: String) -> void:
	id_label.text = "[%d]" % id_num
	if text == "->":
		text = "continue"
	
	if id_num != 0:
		$ColorRect1.visible = false
		$ColorRect2.visible = false
		$Label.visible = false
	option_label.text = text

## this doesn't work for me
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_drag_offset = get_global_mouse_position() - global_position
		elif not event.pressed and get_rect().has_point(get_local_mouse_position()):
			option_selected.emit()
	
	if event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
