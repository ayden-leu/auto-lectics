@icon("uid://bxn4xxvlf1s0e")
@tool
extends Node
class_name InputHandler
## Handles all inputs a player can possibly make.  Emits signals when a player input happens.

## Emitted when the mouse moves.
signal mouse_moved(distanceMoved:Vector2)
## Emitted when the interact button is just pressed.
signal interact_button_pressed
## Emitted when the jump button is pressed.
signal jump_pressed
## Emitted constantly to update the player's current input direction.
signal update_input_direction(newDirection:Vector2)

## Mouse movement sensitivity.
var mouseSentitivity:float = 0.15

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _physics_process(_delta: float) -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	print(input_dir)
	update_input_direction.emit(input_dir)
	
	# Handle jump.
	#if Input.is_action_just_pressed("jump") and player.is_on_floor():
		#player.jump()

	# Get the input direction and handle the movement/deceleration.
	#var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#player.handleDirectionInput(direction)

func _input(event: InputEvent) -> void:
	# https://kidscancode.org/godot_recipes/4.x/3d/basic_fps/
	if event is InputEventMouseMotion:
		#if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		emit_signal("mouse_moved", event.relative * mouseSentitivity)
	
	elif event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	elif event.is_action_pressed("interact"):
		interact_button_pressed.emit()
	
	elif event.is_action_pressed("jump"):
		jump_pressed.emit()
