extends Camera3D
class_name PlayerCamera

@export var focus:Node3D
var actAsFocus:bool = true

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	if(actAsFocus):
		thirdPersonMode()
	else:
		firstPersonMode()

func firstPersonMode() -> void:
	look_at(focus.global_position)

func thirdPersonMode() -> void:
	global_position = focus.global_position
	
