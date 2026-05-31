extends Node3D

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
@onready var instructions_label: Label = $UI/InstructionsLabel
# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.enable()
	CursorHandler.setDefault("hidden")
	CursorHandler.hideNuclear()

	instructions_label.text = """
Start Dialogue Area Test Scene

WASD - Move
Mouse - Look
Esc - Release mouse
Left Click - Capture mouse

Walk close to each NPC.

Expected:
- Entering an NPC's trigger area should automatically start that NPC's dialogue.
- No interaction button is required.
- The moving NPC's trigger area should follow the NPC.
"""
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
