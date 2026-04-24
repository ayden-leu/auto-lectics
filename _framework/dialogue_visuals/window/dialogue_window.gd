@tool
extends Control
class_name DialogueWindow
## [b]Internal-use only.[/b]  A window that appears on the player's screen.
##
## Can be dragged around.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this window is being closed.
signal window_closed()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The header of this window.
@export var headerPanel:Panel
## The label that holds the header text.
@export var headerLabel:Label
## If this window should be able to be closed or not.
@export var canBeClosed:bool:
	set(value):
		canBeClosed = value
		notify_property_list_changed()
## The button that closes this window.
@export var closeButton:Button

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The text that's in the header of this option window.
## [br][br]
## Comes with a getter and setter so you can treat it like a normal variable
## while updating the relevant stuff.
var headerText:String:
	set(value):
		headerLabel.text = value
	get():
		return headerLabel.text

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Is true when the player is holding the select button
## on this option (left mouse click).
var _holdingSelect:bool = false
## [b]Internal-use only.[/b]  Is true when the player is dragging this around.  
var _dragging:bool = false
## [b]Internal-use only.[/b]  The distance between the origin and the mouse
## when it started being dragged.
var _dragOffset := Vector2.ZERO

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if canBeClosed:
		closeButton.pressed.connect(_on_close_button_pressed)

func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_holdingSelect = event.pressed
		if _holdingSelect:
			_dragOffset = get_global_mouse_position() - global_position
	
	if event is InputEventMouseMotion and _holdingSelect:
		_dragging = true
		global_position = get_global_mouse_position() - _dragOffset
	else:
		_dragging = false

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Closes this window.
func close() -> void:
	window_closed.emit()
	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## Moves this window to the center of the screen immediately.
func _center() -> void:
	await get_tree().process_frame
	position = (get_viewport_rect().size - size) / 2

## Gets a random position on screen.
## Unused as it doesn't account for overlap.
func _getRandomPositionOnScreen(window_size: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(
		randf_range(0.0, max(0.0, viewport_size.x - window_size.x)),
		randf_range(0.0, max(0.0, viewport_size.y - window_size.y))
	)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when the close button is pressed.
func _on_close_button_pressed() -> void:
	close()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not headerPanel:
		warnings.push_back(
			"The header panel is not set."
		)
	
	if not headerLabel:
		warnings.push_back(
			"The header label is not set."
		)
	
	if canBeClosed and not closeButton:
		warnings.push_back(
			"A close button is not set."
		)
	
	return warnings

func _validate_property(property: Dictionary) -> void:
	if property.name in ["closeButton"] and not canBeClosed:
		property.usage = PROPERTY_USAGE_NO_EDITOR
