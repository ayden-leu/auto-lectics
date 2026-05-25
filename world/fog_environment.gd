extends Node3D

func _ready() -> void:
	FR_MenuManager.enable() # either enable() or disable()
	FR_WindowManager.enable() # either enable() or disable()
	CursorHandler.setDefault("hidden") # refer to documentation or hover over the function for valid values
	CursorHandler.hideNuclear() # either hideNuclear() or showNuclear()

# don't forget that _process() and _physics_process() exist.
# they'll show up on the auto-complete.
