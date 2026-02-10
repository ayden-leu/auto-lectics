@tool
extends Node
class_name InputHandler

## Emitted when the mouse moves.
signal mouse_moved
## Emitted when the interact button is just pressed.
signal interact_button_pressed

## Mouse movement sensitivity.
var mouseSentitivity:float = 0.15

# NOTE: set up a more generic "player" class if need be
#		for now, just using the Player is fine
## The main player character to control.
@export var player:Player:
	set(value):
		player = value
		update_configuration_warnings()
## A list of nodes that want to know if the mouse has moved.
@export var wantsToKnowMouseMoved:Array[Node3D]
## A list of nodes that want to know if the player hit the interact button.
@export var wantsToKnowWhenInteract:Array[Node3D]

func _ready() -> void:
	for listener in wantsToKnowMouseMoved:
		mouse_moved.connect(listener._onMouseMoved)
	
	for listener in wantsToKnowWhenInteract:
		interact_button_pressed.connect(listener._onInteractPressed)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

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
		#if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		emit_signal("mouse_moved", event.relative * mouseSentitivity)
	
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("interact"):
		interact_button_pressed.emit()




# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not player:
		warnings.push_back(
			"No player has been assigned to the Player property,
		")
	
	for listener in wantsToKnowMouseMoved:
		if not listener.has_method("_onMouseMoved"):
			warnings.push_back(
				listener.name + " doesn't have a _onMouseMoved() method.
			")
		
	for listener in wantsToKnowWhenInteract:
		if not listener.has_method("_onInteractPressed"):
			warnings.push_back(
				listener.name + " doesn't have a _onInteractPressed() method.
			")
	
	return warnings
