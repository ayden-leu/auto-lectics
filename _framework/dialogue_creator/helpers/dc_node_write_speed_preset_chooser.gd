extends DC_BaseNodeChooser

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitteed when the preset is changed by the user.
signal preset_updated(newPreset:String)

# ------------------------------------------------
# enums
# -----------------------------------------s-------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## Whether to add the inherit option or not.
@export var addInherit:bool

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
	var temp:Array[String] = []
	for preset in DialogueDefaults.WRITE_SPEED_PRESETS.keys():
		if not addInherit and preset == "inherit":
			continue
		temp.push_back(preset)

	_fillValueToOptionIndex(temp)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Only here to see signal connections.
func _on_chooser_item_selected(_index:int) -> void:
	super(_index)
	preset_updated.emit(
		chooser.get_item_text(_index)
	)

## [b]Internal-use only.[/b]
## Updatees the preset whene the value is updated.
func _on_value_input_field_updated(newValue:float) -> void:
	if newValue == DialogueDefaults.WRITE_SPEED_PRESETS.slow:
		chosen = "slow"
	elif newValue == DialogueDefaults.WRITE_SPEED_PRESETS.medium:
		chosen = "medium"
	elif newValue == DialogueDefaults.WRITE_SPEED_PRESETS.fast:
		chosen = "fast"
	elif newValue < 0:
		return
	else:
		chosen = "custom"

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
