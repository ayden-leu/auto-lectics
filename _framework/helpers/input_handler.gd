@icon("uid://bxn4xxvlf1s0e")
extends Node
class_name InputHandler
## Handles all inputs a player can possibly make.  Emits signals when a player input happens.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the mouse moves.
signal mouse_moved(distanceMoved:Vector2)
## Emitted when the interact button is just pressed.
signal interact_button_pressed()
## Emitted when the jump button is pressed.
signal jump_pressed()
## Emitted constantly to update the player's current input direction.
signal update_input_direction(newDirection:Vector2)
## Emitted when the "Respawn" key is pressed.
signal respawn()
## Emitted when grapple hook buttons are pressed
signal grapple_pressed()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## Mouse movement sensitivity.
const MOUSE_SENSITIVITY:float = 0.15

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Whether movement inputs should be processed.  Only affects this [InputHandler].
var movementInputEnabled:bool = true

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## Whether movement inputs should be processed.  Affects all [InputHandler]s.
static var _movementInputEnabledGlobal:bool = true
## Whether interaction inputs should be processed.  Affects all [InputHandler]s.
static var _interactionEnabledGlobal:bool = true
## Whether the jump input should be processed.  Affects all [InputHandler]s.
static var _jumpEnabledGlobal:bool = true
## Whether the respawn input should be processed.  Affects all [InputHandler]s.
static var _respawnEnabledGlobal:bool = true
## The mouse mode before [method showCursorTemp] or [method hideCursorTemp] was ran.
static var _savedMouseMode:Input.MouseMode = Input.MOUSE_MODE_MAX

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	#if Engine.is_editor_hint():
		#return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta: float) -> void:
	var input_dir:Vector2 = Vector2.ZERO
	if _movementInputEnabledGlobal and movementInputEnabled:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	update_input_direction.emit(input_dir)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _interactionEnabledGlobal:
		interact_button_pressed.emit()

	elif event.is_action_pressed("jump") and _jumpEnabledGlobal:
		jump_pressed.emit()

	elif event.is_action_pressed("close_game"):
		get_tree().quit()

	elif event.is_action_pressed("respawn") and _respawnEnabledGlobal:
		respawn.emit()

	if event.is_action_pressed("grapple") and _movementInputEnabledGlobal and movementInputEnabled:
		grapple_pressed.emit()

	# https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/
	if event is InputEventMouseMotion:
		emit_signal("mouse_moved", event.relative * MOUSE_SENSITIVITY)
	
	#if Input.is_action_just_pressed("open_blueprint"):
		#var focused_control := get_viewport().gui_get_focus_owner()
		#if focused_control != null:
			#return
		#FR_WindowManager.createBlueprintWindow()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Shows the cursor.  Helpful if you want the player to interact with menus.
static func showCursor() -> void:
	print("show cursor")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## Like [method showCursor], but saves the current mouse mode to [member _savedMouseMode].
static func showCursorTemp() -> void:
	if _savedMouseMode == Input.MOUSE_MODE_MAX:
		print("show cursor temp")
		_savedMouseMode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## Hides the cursor.  Helpful if you want the player to move the camera around.
static func hideCursor() -> void:
	print("hide cursor")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Like [method hideCursor], but saves the current mouse mode to [member _savedMouseMode].
static func hideCursorTemp() -> void:
	if _savedMouseMode == Input.MOUSE_MODE_MAX:
		print("hide cursor temp")
		_savedMouseMode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Sets the current mouse mode to [member _savedMouseMode].
static func restoreCursorMode() -> void:
	print("restore cursor")
	if _savedMouseMode == Input.MOUSE_MODE_MAX:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(_savedMouseMode)
	_savedMouseMode = Input.MOUSE_MODE_MAX

## Lets movement inputs be processed.
static func enableMovementInputGlobal() -> void:
	_movementInputEnabledGlobal = true

## Prevents movement inputs from being processed.
static func disableMovementInputGlobal() -> void:
	_movementInputEnabledGlobal = false

## Lets interaction inputs be processed.
static func enableInteractionInputGlobal() -> void:
	_interactionEnabledGlobal = true

## Prevents interaction inputs from being processed.
static func disableInteractionInputGlobal() -> void:
	_interactionEnabledGlobal = false

## Lets jump inputs be processed.
static func enableJumpInputGlobal() -> void:
	_jumpEnabledGlobal = true

## Prevents jump inputs from being processed.
static func disableJumpInputGlobal() -> void:
	_jumpEnabledGlobal = false

## Lets the respawn input be processed.
static func enableRespawnInputGlobal() -> void:
	_respawnEnabledGlobal = true

## Prevents the respawn input from being processed.
static func disableRespawnInputGlobal() -> void:
	_respawnEnabledGlobal = false

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
