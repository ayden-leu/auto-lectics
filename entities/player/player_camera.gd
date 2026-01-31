@tool
extends Camera3D
class_name PlayerCamera

@export var focus:Node3D:
	set(newFocus):
		focus = newFocus
		update_configuration_warnings()

var actAsFocus:bool = true

func _ready() -> void:
	actAsFocus = true

func _process(_delta: float) -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	if(actAsFocus):
		firstPersonMode()
	else:
		thirdPersonMode()

func firstPersonMode() -> void:
	global_position = focus.cameraAnchor.global_position

func thirdPersonMode() -> void:
	global_position = focus.cameraAnchor.global_position
	look_at(focus.global_position)

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
