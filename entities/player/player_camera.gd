@tool
extends Node3D
class_name PlayerCamera
## Holds both the player's camera and the HUD node.  Might be switched to a Camera3D node if time allows us to relook at the camera setup.

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
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	actAsFocus = true
	rotation = focus.rotation


# Since Interaction Raycast is handled by the player's rotation, 
# I made it so the camera just matches the player and camera anchor's angle.
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
	
	#if Input.is_action_just_pressed("debug_2"):
		#actAsFocus = !actAsFocus

## Handles logic for first person mode.
func firstPersonMode() -> void:
	camera.position = Vector3.ZERO
	camera.rotation_degrees = Vector3.ZERO

## Handles logic for third person mode.
func thirdPersonMode() -> void:
	camera.position = distanceFromOrigin
	camera.look_at(global_position)

## Rotates the camera horizontally and vertically when the mouse moves
func _on_mouse_moved(distanceMoved:Vector2) -> void:
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
