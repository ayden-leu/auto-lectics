extends Node3D

@onready var instructions_label: Label = $UI/InstructionsLabel

func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("hidden")
	CursorHandler.hideNuclear()

# don't forget that _process() and _physics_process() exist.
# they'll show up on the auto-complete.
