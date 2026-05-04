@tool
@icon("uid://bbxaj8rh6jfm6")
extends Control
class_name DialogueWindow
## [b]Internal-use only.[/b]  A window that appears on the player's screen.
##
## Can be dragged around.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this window is being closed.
signal window_closed(me:DialogueWindow)
## Emitted when this window is no longer being moved by the user.
signal window_dropped(me:DialogueWindow)

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
## How far this window can be off the screen, in pixels,
## before it gets snapped back onto the screen.
@export var offscreenThresold: float = 0

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The type of this window.
var windowType:String

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
		get_parent().move_child(self, -1)
		_holdingSelect = event.pressed
		if _holdingSelect:
			_dragOffset = get_global_mouse_position() - global_position
		else:
			window_dropped.emit(self)
	
	if event is InputEventMouseMotion and _holdingSelect:
		_dragging = true
		global_position = get_global_mouse_position() - _dragOffset
	else:
		_dragging = false

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Gets the positions of each corner of this window relative to the
## top left corner of this window.
## [br][br]
## Resulting dictionary has the following keys:
## [code]"topLeft"[/code], [code]"topRight"[/code],
## [code]"bottomLeft"[/code], [code]"bottomRight"[/code]
## [br][br]
## If you want their positions on the screen, use [method getGlobalCornerPositions].
func getLocalCornerPositions() -> Dictionary[String, Vector2]:
	return {
		"topLeft":     position + Vector2(0     , 0     ),
		"topRight":    position + Vector2(size.x, 0     ),
		"bottomLeft":  position + Vector2(0     , size.y),
		"bottomRight": position + Vector2(size.x, size.y)
	}

## Gets the positions of each corner of this window relative to the
## top left corner of this window.
## [br][br]
## Resulting dictionary has the following keys:
## [code]"topLeft"[/code], [code]"topRight"[/code],
## [code]"bottomLeft"[/code], [code]"bottomRight"[/code]
## [br][br]
## If you want their positions relative to this window, use [method getLocalCornerPositions].
func getGlobalCornerPositions() -> Dictionary[String, Vector2]:
	return {
		"topLeft":     global_position + Vector2(0     , 0     ),
		"topRight":    global_position + Vector2(size.x, 0     ),
		"bottomLeft":  global_position + Vector2(0     , size.y),
		"bottomRight": global_position + Vector2(size.x, size.y)
	}

## Closes this window.
func close() -> void:
	window_closed.emit(self)
	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## Moves this window to the center of the screen immediately.
func _center() -> void:
	position = (get_viewport_rect().size - size) / 2

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
