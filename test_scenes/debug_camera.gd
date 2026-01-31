@tool
extends Camera3D

@export var mainCamera:Camera3D:
	set(newCamera):
		if mainCamera and newCamera:
			mainCamera.current = false
			newCamera.current = true
		mainCamera = newCamera
		update_configuration_warnings() # Dev-ing stuff

func _ready() -> void:
	mainCamera.current = true

func _process(_delta: float) -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	# Currently set to:  Enter
	# Check Project > Input Map to modify keybinds
	if Input.is_action_just_pressed("debug_1"):
		mainCamera.current = !mainCamera.current
		current = !mainCamera.current
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not mainCamera:
		warnings.push_back(
			"No Main Camera set.
		")
	
	return warnings
