@tool
extends Node3D
class_name PlayerCamera
## Holds both the player's camera.
## Might be switched to a Camera3D node if time allows us to relook at the camera setup.

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
## The target the camera wants to look at.
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
		
	#print(name + ": mouse moved")
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
