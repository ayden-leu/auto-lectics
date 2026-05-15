@tool
@icon("uid://bbxaj8rh6jfm6")
extends Control
class_name DialogueWindow
## [b]Internal-use only.[/b]  A window that appears on the player's screen.
##
## Can be dragged around.
## [br][br]
## Comes with the following optional SFX events:[br]
## - spawn:  plays when the window is spawned.[br]
## - close:  plays when the window is closed.[br]
## - hover:  plays when the player hovers their cursor over the window.[br]
## - click:  plays when the player clicks the window.[br]
## - drop:   plays when the player drops the window after letting it go.[br]

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
## The [SfxEventHandler] that plays SFX events.
@export var sfxEventHandler:SfxEventHandler

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
## [b]Internal-use only.[/b]
## Is true when the player's cursor is hovering over the window.
var _hovering:bool = false:
	set(newState):
		if newState == _hovering:
			return
		_hovering = newState
		if _hovering and sfxEventHandler.getPlayerForEvent("hover"):
			sfxEventHandler.play("hover")
## [b]Internal-use only.[/b]
## Is true when the player is holding the select button on this option (left mouse click).
var _holdingSelect:bool = false:
	set(newState):
		if newState == _holdingSelect:
			return

		_holdingSelect = newState
		if _holdingSelect and sfxEventHandler.getPlayerForEvent("click"):
			sfxEventHandler.play("click")
		elif sfxEventHandler.getPlayerForEvent("drop"):
			sfxEventHandler.play("drop")
## [b]Internal-use only.[/b]
## Is true when the player is dragging this around.
var _dragging:bool = false
## [b]Internal-use only.[/b]
## The distance between the origin and the mouse when it started being dragged.
var _dragOffset := Vector2.ZERO
## [b]Internal-use only.[/b]
## The original cursor shape set in the editor.
var _originalCursorShape:CursorShape

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_originalCursorShape = mouse_default_cursor_shape

	if canBeClosed:
		closeButton.pressed.connect(_on_close_button_pressed)

	if sfxEventHandler.getPlayerForEvent("spawn"):
		sfxEventHandler.play("spawn")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or not visible:
		return

	_hovering = _positionInWindow(get_global_mouse_position())

	if _dragging:
		mouse_default_cursor_shape = Control.CURSOR_CAN_DROP
	elif _hovering:
		mouse_default_cursor_shape = _originalCursorShape

func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if not visible:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		move_to_front()
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

	var sfxPlayer:AudioStreamPlayer = sfxEventHandler.getPlayerForEvent("close")
	if sfxPlayer and sfxEventHandler.sfxIds.get("close", "") != "":
		sfxEventHandler.play("close")
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		hide()
		await sfxPlayer.finished

	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Returns true if the given position in within this window.
func _positionInWindow(pos:Vector2) -> bool:
	var corners:Dictionary = getGlobalCornerPositions()

	return (
		pos.x > corners.topLeft.x and pos.x < corners.bottomRight.x and
		pos.y > corners.topLeft.y and pos.y < corners.bottomRight.y
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
