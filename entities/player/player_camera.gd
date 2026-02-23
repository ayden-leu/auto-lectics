@tool
extends Node3D
class_name PlayerCamera

## The target the camera wants to look at.
@export var focus:Node3D:
	set(newFocus):
		focus = newFocus
		update_configuration_warnings()

## The actual camera.
@onready var camera:Camera3D = $Camera3D

## Whether the camera is in first person mode or not.
var actAsFocus:bool = true
## How far away from the focus the camera should be when in third person mode.
var distanceFromOrigin:Vector3 = Vector3(0, 5, 10)

### Tune camera sensitivity
#@export var mouse_sensitivity := 1
### Max angle which the camera can turn to; prevents flipping at top
#@export var max_pitch_degrees := 89.0
### Store pitch (vertical rotation)
#var _pitch_deg: float = 0.0

func _ready() -> void:
	actAsFocus = true
	rotation = focus.rotation
	## Initialise from current rotation
	#_pitch_deg = rotation_degrees.x


## Since Interaction Raycast is handled by the player's rotation, 
## I made it so the camera just matches the player and camera anchor's angle.
func _process(_delta: float) -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	if not focus:
		return
	
	#global_position = focus.cameraAnchor.global_position
	global_transform = focus.cameraAnchor.global_transform
	
	## follow player yaw (horizontal rotation). pitch is handled by camera
	#rotation_degrees.y = focus.rotation_degrees.y
	#rotation_degrees.x = _pitch_deg
	
	if(actAsFocus):
		firstPersonMode()
	else:
		thirdPersonMode()
	
	if Input.is_action_just_pressed("debug_2"):
		actAsFocus = !actAsFocus

## Handles logic for first person mode.
func firstPersonMode() -> void:
	camera.position = Vector3.ZERO
	camera.rotation_degrees = Vector3.ZERO

## Handles logic for third person mode.
func thirdPersonMode() -> void:
	camera.position = distanceFromOrigin
	camera.look_at(global_position)

## Rotates the camera horizontally and vertically when the mouse moves
func _onMouseMoved(distanceMoved:Vector2) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	pass
	## update camera angle
	#_pitch_deg += (-distanceMoved.y) * mouse_sensitivity
	## Clamp pitch so we never flip
	#_pitch_deg = clamp(_pitch_deg, -max_pitch_degrees, max_pitch_degrees)




# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not focus and self != get_tree().edited_scene_root:
		warnings.push_back(
			"No object has been assigned to the Focus property.
		")
	
	return warnings
