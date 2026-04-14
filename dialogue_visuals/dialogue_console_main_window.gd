extends Panel


var _dragging := false
var _drag_offset := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_drag_offset = get_global_mouse_position() - global_position
	
	if event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
