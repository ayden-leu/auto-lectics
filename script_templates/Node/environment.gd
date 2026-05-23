# meta-default: false
# meta-name: Environment Script Template
# meta-description: Provides the functions needed for an environment.

extends _BASE_

func _ready() -> void:
_TS_FR_MenuManager. # either enable() or disable()
_TS_FR_WindowManager. # either enable() or disable()
_TS_CursorHandler.setDefault() # refer to documentation or hover over the function for valid values
_TS_CursorHandler. # either hideNuclear() or showNuclear()

# don't forget that _process() and _physics_process() exist.
# they'll show up on the auto-complete.
