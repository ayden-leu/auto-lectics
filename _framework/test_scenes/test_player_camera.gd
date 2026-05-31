extends Node3D

@onready var player_camera: PlayerCamera = $PlayerCamera
@onready var focus_target: Node3D = $FocusTarget
@onready var camera_anchor: Node3D = %cameraAnchor
@onready var instructions_label: Label = $UI/InstructionsLabel

func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("hidden")
	CursorHandler.hideNuclear()

	player_camera.focus = focus_target

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	instructions_label.text = """
Player Camera Test Scene

Mouse - Rotate camera
1 - First person mode
3 - Third person mode
Esc - Release mouse
Left Click - Capture mouse again

Expected:
- Camera follows the FocusTarget
- Mouse movement rotates the view
- 1 switches to first-person
- 3 switches to third-person
"""

var mouse_sensitivity: float = 0.15
var camera_pitch: float = 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_pitch = clamp(
			camera_pitch - event.relative.y * mouse_sensitivity,
			-80.0,
			80.0
		)

		focus_target.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_anchor.rotation_degrees.x = camera_pitch

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			player_camera._actAsFocus = true
			instructions_label.text = "Mode: First Person"

		elif event.keycode == KEY_3:
			player_camera._actAsFocus = false
			instructions_label.text = "Mode: Third Person"

		elif event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
