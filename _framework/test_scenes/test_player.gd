extends Node3D

func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("hidden")
	CursorHandler.hideNuclear()

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass
# don't forget that _process() and _physics_process() exist.
# they'll show up on the auto-complete.
