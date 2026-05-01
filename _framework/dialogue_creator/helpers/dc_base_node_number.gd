extends DC_BaseNodeField
class_name DC_BaseNodeNumber

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
## Holds the value of this field.
@export var valueHolder:SpinBox

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The value of this field.  Setting this updates the value visually.
var value:float:
	get():
		return valueHolder.value
	set(newValue):
		valueHolder.value = newValue

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is esmitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when the field is updated by user.
func _on_input_field_value_changed(_value:float) -> void:
	field_updated.emit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
