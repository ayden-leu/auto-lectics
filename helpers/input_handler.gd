@tool
extends Node
class_name InputHandler

signal mouse_moved
signal interact_button_pressed

var mouseSentitivity:float = 0.15

# NOTE: set up a more generic "player" class if need be
#		for now, just using the Player is fine
@export var player:Player:
	set(value):
		player = value
		update_configuration_warnings()
@export var wantsToKnowMouseMoved:Array[Node3D]
@export var wantsToKnowWhenInteract:Array[Node3D]

func _ready() -> void:
	for listener in wantsToKnowMouseMoved:
		connect("mouse_moved", listener._onMouseMoved)
	
	for listener in wantsToKnowWhenInteract:
		connect("interact_button_pressed", listener._onInteractPressed)

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	if not player:
		return
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.jump()

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	player.handleDirectionInput(direction)

func _input(event: InputEvent) -> void:
	# https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
			emit_signal("mouse_moved", event.relative * mouseSentitivity)
		
	if Input.is_action_just_pressed("interact"):
		emit_signal("interact_button_pressed")



# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not player:
		warnings.push_back(
			"No player has been assigned to the Player property,
		")
	
	return warnings
