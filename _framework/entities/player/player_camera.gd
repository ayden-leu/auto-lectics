@tool
@icon("uid://dycpbdo33wb4c")
extends Node3D
class_name PlayerCamera
## Controls the camera used by the player.
##
## Supports both first-person and third-person camera modes while
## automatically following a target player.
##
##
##
## [br][br][br]
## [b]Using:[/b][br]
## To use, add the pre-built [PlayerCamera] scene to your gameplay scene.
## Then assign the desired player to [member focus].
## [br][br]
## When [member _actAsFocus] is enabled, the camera operates in
## first-person mode and matches the position of the player's
## camera anchor.
## [br][br]
## When [member _actAsFocus] is disabled, the camera operates in
## third-person mode and positions itself using
## [member _distanceFromOrigin].
## [br][br]
## This camera automatically follows the assigned [Player]
## and updates its position every frame.
##
##
##
## [br][br][br]
## [b]Notes:[/b][br]
## Despite its name, it can also be used to look at non-[Player] things.
## Just set [member focus] to the thing you want to look at.
## [br][br]
## The base node type might be switched to a [Camera3D] node directly if the camera
## system is redesigned in the future.

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The [Node3D] this camera should follow.
@export var focus:Node3D:
	set(newFocus):
		focus = newFocus
		update_configuration_warnings()
## Whether the camera is in first person mode or not.
@export var _actAsFocus:bool = true
## How far away from the focus the camera should be when in third person mode.
@export var _distanceFromOrigin:Vector3 = Vector3(0, 5, 10)

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## The actual camera.
@onready var camera:Camera3D = %Camera3D

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return

	_actAsFocus = true
	rotation = focus.rotation

func _process(_delta: float) -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	if not focus:
		return

	global_transform = focus.cameraAnchor.global_transform

	if(_actAsFocus):
		_firstPersonMode()
	else:
		_thirdPersonMode()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for first person mode.
func _firstPersonMode() -> void:
	camera.position = Vector3.ZERO
	camera.rotation_degrees = Vector3.ZERO

## [b]Internal-use only.[/b]  Handles logic for third person mode.
func _thirdPersonMode() -> void:
	camera.position = _distanceFromOrigin
	camera.look_at(global_position)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Rotates the camera horizontally and vertically when the mouse moves
func _on_mouse_moved(distanceMoved:Vector2) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	rotation_degrees.x += -distanceMoved.y
	rotation_degrees.y += -distanceMoved.x

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if not focus and self != get_tree().edited_scene_root:
		warnings.push_back(
			"No object has been assigned to the Focus property.
		")

	return warnings
