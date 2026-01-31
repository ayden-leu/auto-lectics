extends Camera3D
class_name PlayerCamera

# TODO:  move input handling to its own node.
# TODO:  move camera settings to a global master node?
# TODO:  maybe redo movement code

var mouseSentitivity:float = 0.15

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
		if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
			rotation_degrees.x += -event.relative.y * mouseSentitivity
			rotation_degrees.y += -event.relative.x * mouseSentitivity
			focus.rotation_degrees.y += -event.relative.x * mouseSentitivity
		
	if Input.is_action_just_pressed("interact"):
		# TODO: make a better way to get the NPC we're acting with
		# 		making assumptions about the node hierarchy isn't good
		if interactionRaycast.get_collider() is Area3D:
			interactionRaycast.get_collider().get_parent()._onInteraction()
		
	if Input.is_action_just_pressed("debug_1"):
		actAsFocus = !actAsFocus
	
	if Input.is_action_pressed("debug_2") or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func firstPersonMode() -> void:
	global_position = focus.global_position

func thirdPersonMode() -> void:
	global_position = focus.cameraAnchor.global_position
	look_at(focus.global_position)
	
	
