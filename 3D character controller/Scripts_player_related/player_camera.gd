extends Camera3D
class_name PlayerCamera

var mouseSentitivity:float = 0.05

@export var focus:Node3D
var actAsFocus:bool = true:
	set(value):
		actAsFocus = value

@onready var interactionRaycast = $RayCast3D

func _ready() -> void:
	actAsFocus = true

func _process(_delta: float) -> void:
	if(actAsFocus):
		firstPersonMode()
	else:
		thirdPersonMode()

func _input(event: InputEvent) -> void:
	# https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/
	if event is InputEventMouseMotion:
		rotation_degrees.x += -event.relative.y * mouseSentitivity
		rotation_degrees.y += -event.relative.x * mouseSentitivity
		focus.rotation_degrees.y += -event.relative.x * mouseSentitivity
		
	if Input.is_action_just_pressed("interact"):
		interactionRaycast.get_collider().get_parent()._onInteraction()
		
	if Input.is_action_just_pressed("debug_1"):
		actAsFocus = !actAsFocus
	
	if Input.is_action_just_pressed("debug_2"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func firstPersonMode() -> void:
	global_position = focus.global_position

func thirdPersonMode() -> void:
	global_position = focus.cameraAnchor.global_position
	look_at(focus.global_position)
	
	
