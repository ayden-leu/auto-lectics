extends DC_FieldOption
class_name DC_TypeFieldOption
## TODO

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------
## The two types of types a [DC_BaseNode] can be.
enum VALID_TYPES {
	DIALOGUE,  ## Refer to [member DialogueDefaults.DIALOGUE_TYPES].
	OPTION     ## Refer to [member DialogueDefaults.OPTION_TYPES].
}

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The type of this [DC_BaseNode].
@export var type:VALID_TYPES

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The chosen type.
var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
	get():
		if type == VALID_TYPES.DIALOGUE:
			return DialogueDefaults.DIALOGUE_TYPES[chooser.selected]
		elif type == VALID_TYPES.OPTION:
			return DialogueDefaults.OPTION_TYPES[chooser.selected]
		printerr("field_option_type: Unhandled option type: ", type)
		return "error"

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if type == VALID_TYPES.DIALOGUE:
		fillValueToOptionIndex(DialogueDefaults.DIALOGUE_TYPES)
	elif type == VALID_TYPES.OPTION:
		fillValueToOptionIndex(DialogueDefaults.OPTION_TYPES)
	
	option = DialogueDefaults.DEFAULT_DIALOGUE.type

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
