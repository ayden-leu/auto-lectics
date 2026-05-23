@tool
extends _BASE_

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

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
_TS_if Engine.is_editor_hint():
_TS__TS_return
_TS_super()
_TS_windowType =

func _process(_delta: float) -> void:
_TS_if Engine.is_editor_hint():
_TS__TS_return
_TS_super(_delta)

func _gui_input(event: InputEvent) -> void:
_TS_if Engine.is_editor_hint():
_TS__TS_return
_TS_super(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Closes this window
func close() -> void:
_TS_super()

## Removes this from the scene.
## If you want to close this window, run [method close] instead.
func kill() -> void:
_TS_queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
_TS_var warnings:Array[String] = []

_TS_warnings.append_array(super())
_TS_return warnings

func _validate_property(property: Dictionary) -> void:
_TS_super(property)
