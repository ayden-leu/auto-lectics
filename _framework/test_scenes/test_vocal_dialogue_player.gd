extends Node

func _ready() -> void:
	FR_MenuManager.disable() # either enable() or disable()
	FR_WindowManager.disable() # either enable() or disable()
	CursorHandler.setDefault("shown") # refer to documentation or hover over the function for valid values
	CursorHandler.showNuclear()	 # either hideNuclear() or showNuclear()

# don't forget that _process() and _physics_process() exist.
# they'll show up on the auto-complete.
