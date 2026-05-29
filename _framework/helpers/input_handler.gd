@icon("uid://bxn4xxvlf1s0e")
extends Node
class_name InputHandler
## Handles all inputs a player can possibly make.
##
## When a player executes and input, a signal for that input will be emitted.
## To use, attach this to your node and connect the corresponding signals.
## [br][br]
## The input direction passed with the [signal update_input_direction] signal
## is normalized, meaning diagonal inputs will be equal to the square root of 2
## instead of 1.
## [br][br]
## The move distance passed with the [signal mouse_moved] signal is multiplied
## by [member MOUSE_SENSITIVITY] before being sent along the way.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the mouse moves.
## [code]distanceMoved[/code] is multiplied by [member MOUSE_SENSITIVITY] before
## being sent with the signal.

signal mouse_moved(distanceMoved:Vector2)
## Emitted when the [code]interact[/code] action is pressed.
signal interact_button_pressed()
## Emitted when the [code]jump[/code] action is pressed.
signal jump_pressed()
## Emitted constantly to update the player's current input direction.
## [code]newDirection[/code] is normalized, meaning diagonal inputs will be
## equal to the square root of 2 instead of 1.

signal update_input_direction(newDirection:Vector2)
## Emitted when the [code]respawn[/code] action is pressed.
signal respawn()
## Emitted when grapple hook buttons are pressed
signal grapple_pressed()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## Multiplier applied to raw mouse motion before emitting [signal mouse_moved].
## [br][br]
## Larger values make emitted mouse movement stronger.  Camera scripts may also apply their own sensitivity after receiving the signal.
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
## Whether movement input should be processed by this InputHandler instance.
## [br][br]
## When false, this instance emits [constant Vector2.ZERO] through [signal update_input_direction] even if the player is pressing movement keys.  This does not affect other [InputHandler] nodes.
var movementInputEnabled:bool = true

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Whether movement input should be processed by all [InputHandler] instances.
static var _movementInputEnabledGlobal:bool = true

## Whether interaction inputs should be processed.  Affects all [InputHandler]s.
static var _interactionEnabledGlobal:bool = true
## Whether the jump input should be processed.  Affects all [InputHandler]s.
static var _jumpEnabledGlobal:bool = true
## Whether the respawn input should be processed.  Affects all [InputHandler]s.
static var _respawnEnabledGlobal:bool = true


# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

## [b]Internal-use Only.[/b]
## Captures the mouse when this handler enters the scene tree.
## [br][br]
## This lets first-person camera controls receive relative mouse movement during gameplay.
func _ready() -> void:
	#if Engine.is_editor_hint():
		#return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## [b]Internal-use Only.[/b]
## Emits [signal update_input_direction] every physics frame.
## [br][br]
## If either [member movementInputEnabled] or the global movement-input flag is false, this emits [constant Vector2.ZERO].

func _physics_process(_delta: float) -> void:
	var input_dir:Vector2 = Vector2.ZERO
	if _movementInputEnabledGlobal and movementInputEnabled:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	update_input_direction.emit(input_dir)

## [b]Internal-use Only.[/b]
## Handles action presses and mouse motion.
## [br][br]
## Emits the matching signals for [code]interact[/code], [code]jump[/code], [code]respawn[/code], and mouse movement.  If [code]close_game[/code] is pressed, the scene tree quits immediately.
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
static func enableMovementInputGlobal() -> void:
	_movementInputEnabledGlobal = true

## Prevents all [InputHandler] instances from processing movement input.
## [br][br]
## While disabled, [signal update_input_direction] emits [constant Vector2.ZERO] from every instance.
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
