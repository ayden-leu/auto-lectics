extends Control
class_name DC_FieldOption
## The base class used for [Control] nodes that manage any [OptionButton] fields.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the [member chooser] value gets updated.
signal option_changed()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## Holds the [OptionButton] that will have options to choose from.
@export var chooser:OptionButton

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Helper variable to convert option values to their list index.
var valueToOptionIndex:Dictionary = {}

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Fills [member chooser] and [member valueToOptionIndex] with potential options to pick from.
func fillValueToOptionIndex(referenceArray:Array[String], capitalize:bool = true) -> void:
	for i:int in range(referenceArray.size()):
		var value:String = referenceArray[i]
		chooser.add_item(value.capitalize() if capitalize else value)
		valueToOptionIndex.set(value, i)

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when [member chooser]'s value gets updated. 
func _on_chooser_updated(_index:int) -> void:
	option_changed.emit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
