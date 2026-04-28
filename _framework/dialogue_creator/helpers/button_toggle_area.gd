extends CheckBox
class_name DC_SectionToggle
## A [CheckBox] who's purpose is to hide/show various nodes when pressed.
## It's a [CheckBox] and not a [CheckButton] because the icon is on the left.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the [member fields] get hidden/shown.
signal resize()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The nodes to hide/show when the button is pressed.
@export var fields:Array[Control]

# ------------------------------------------------
# onready variables
# ------------------------------------------------

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
	toggle_mode = true
	_on_toggled(false)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when the button gets fully pressed.
func _on_toggled(toggled_on: bool) -> void:
	for field in fields:
		field.visible = toggled_on
	resize.emit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
