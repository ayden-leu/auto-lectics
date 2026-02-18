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

func _ready() -> void:
	actAsFocus = true
	rotation = focus.rotation

func _process(_delta: float) -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	global_position = focus.cameraAnchor.global_position
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
		
	#print(name + ": mouse moved")
	rotation_degrees.x += -distanceMoved.y
	rotation_degrees.y += -distanceMoved.x



# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not focus and self != get_tree().edited_scene_root:
		warnings.push_back(
			"No object has been assigned to the Focus property.
		")
	
	return warnings
