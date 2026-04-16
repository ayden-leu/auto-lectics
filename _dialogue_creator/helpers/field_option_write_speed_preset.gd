extends DC_FieldOption
class_name DC_WriteSpeedPresetFieldOption
## TODO

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
## The chosen write speed preset.
var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
		option_changed.emit()
	get():
		return DialogueDefaults.WRITE_SPEED_PRESETS.keys()[chooser.selected]

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	var keys:Array = DialogueDefaults.WRITE_SPEED_PRESETS.keys()
	var typingMoment:Array[String] = []
	for key in keys:
		typingMoment.push_back(key as String)
	fillValueToOptionIndex(typingMoment)
	
	option = DialogueDefaults.DEFAULT_DIALOGUE.writeSpeed

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when a write speed preset is chosen.
func _on_item_selected(_index: int) -> void:
	option = option

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
