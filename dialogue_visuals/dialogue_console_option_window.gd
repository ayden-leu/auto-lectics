@tool
extends Button
class_name DialogueConsoleOptionWindow
## [b]Internal-use only.[/b]  A dialogue option window that spawns when a user
## is able to continue a dialogue event.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this option is chosen.
signal option_selected()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## The label that denotes which "index" is associated with this option.
@onready var id_label: Label = %ID
## The label that holds the text associated with this option.
@onready var option_label: Label = %Text

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Is true when the player is dragging this window around.
var _dragging := false
## [b]Internal-use only.[/b]  The distance between the origin and the mouse
## when it started being dragged.
var _drag_offset := Vector2.ZERO



# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_drag_offset = get_global_mouse_position() - global_position
	
	if event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
func set_option_data(id_num: int, text: String) -> void:
	id_label.text = "[%d]" % id_num
	if text == "->":
		text = "continue"
	
	if id_num != 0:
		$ColorRect2.visible = false
		$Label.visible = false
	option_label.text = text

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------


func _on_pressed() -> void:
	option_selected.emit()
