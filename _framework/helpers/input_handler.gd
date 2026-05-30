@icon("uid://bxn4xxvlf1s0e")
extends Node
class_name InputHandler
## Handles all inputs a player can possibly make.
##
## Well, almost all of them.  [code]open_blueprint[/code] gets handled by [WindowManager]
## since the input shouldn't be handled while the user is typing.
## [br][br]
## When a player executes and input, a signal for that input will be emitted.
## [br][br][br]
## [b]Using[/b][br]
## To use, attach this to your node and connect the corresponding signals
## to functions in your node's script.
## [br][br][br]
## [b]Things to keep in mind:[/b][br]
## The input direction passed with the [signal update_input_direction] signal
## is normalized, meaning diagonal inputs will be equal to [code]the square root of 2[/code]
## instead of [code]1[/code].
## [br][br]
## The move distance passed with the [signal mouse_moved] signal is multiplied
## by [member MOUSE_SENSITIVITY] before being sent along the way.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the mouse moves.
## [br]
## [code]distanceMoved[/code] is multiplied by [member MOUSE_SENSITIVITY] before
## being sent with the signal.
signal mouse_moved(distanceMoved:Vector2)
## Emitted when the [code]interact[/code] action is pressed.
signal interact_button_pressed()
## Emitted when the [code]jump[/code] action is pressed.
signal jump_pressed()
## Emitted constantly to update the player's current input direction.
## [br]
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
## [br]
## Larger values make emitted mouse movement stronger.
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
## When [code]false[/code], this instance emits [constant Vector2.ZERO] through [signal update_input_direction]
## even if the player is pressing movement keys.
## Does not affect all InputHandlers globally.
## (i.e one InputHandler having this [code]false[/code] only affects that one InputHandler).
var movementInputEnabled:bool = true

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Whether movement input should be processed by all InputHandler instances.
static var _movementInputEnabledGlobal:bool = true
## [b]Internal-use Only.[/b]
## Whether interaction inputs should be processed.  Affects all InputHandlers.
static var _interactionEnabledGlobal:bool = true
## [b]Internal-use Only.[/b]
## Whether the jump input should be processed.  Affects all InputHandlers.
static var _jumpEnabledGlobal:bool = true
## [b]Internal-use Only.[/b]
## Whether the respawn input should be processed.  Affects all InputHandlers.
static var _respawnEnabledGlobal:bool = true

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _physics_process(_delta: float) -> void:
	# handle inputted directions
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
## Lets movement inputs be processed for all InputHandlers.
static func enableMovementInputGlobal() -> void:
	_movementInputEnabledGlobal = true

## Prevents all [InputHandler] instances from processing movement input.
## [br][br]
## While disabled, [signal update_input_direction] emits [constant Vector2.ZERO] from every instance.
static func disableMovementInputGlobal() -> void:
	_movementInputEnabledGlobal = false

## Lets interaction inputs be processed for all InputHandlers.
static func enableInteractionInputGlobal() -> void:
	_interactionEnabledGlobal = true

## Prevents interaction inputs from being processed for all InputHandlers.
static func disableInteractionInputGlobal() -> void:
	_interactionEnabledGlobal = false

## Lets jump inputs be processed for all InputHandlers.
static func enableJumpInputGlobal() -> void:
	_jumpEnabledGlobal = true

## Prevents jump inputs from being processed for all InputHandlers.
static func disableJumpInputGlobal() -> void:
	_jumpEnabledGlobal = false

## Lets the respawn input be processed for all InputHandlers.
static func enableRespawnInputGlobal() -> void:
	_respawnEnabledGlobal = true

## Prevents the respawn input from being processed for all InputHandlerss.
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
