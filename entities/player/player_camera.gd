@tool
extends Node3D
class_name PlayerCamera

@export var focus:Node3D:
	set(newFocus):
		focus = newFocus
		update_configuration_warnings()

@onready var camera:Camera3D = $Camera3D

var actAsFocus:bool = true
var distanceFromOrigin:Vector3 = Vector3(0, 5, 10)

func _ready() -> void:
	actAsFocus = true

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

func firstPersonMode() -> void:
	camera.position = Vector3.ZERO
	camera.rotation_degrees = Vector3.ZERO

func thirdPersonMode() -> void:
	camera.position = distanceFromOrigin
	camera.look_at(global_position)

# Rotates the camera horizontally and vertically when the mouse moves
func _onMouseMoved(distanceMoved:Vector2) -> void:
	#print(name + ": mouse moved")
	rotation_degrees.x += -distanceMoved.y
	rotation_degrees.y += -distanceMoved.x



# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not focus:
		warnings.push_back(
			"No object has been assigned to the Focus property,
		")
	
	return warnings
