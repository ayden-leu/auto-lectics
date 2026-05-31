extends DC_BaseNodeNumber

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
## Only here to see what signals are connected.
func _on_input_field_value_changed(_value:float) -> void:
	super(_value)

## [b]Internal-use only.[/b]
## Updates the value when a preset is chosen.
func _on_preset_chooser_updated(newPreset:String) -> void:
	valueHolder.get_line_edit().editable = true
	if newPreset == "custom":
		return
	elif newPreset in ["npcDefault", "inherit"]:
		valueHolder.get_line_edit().editable = false
		valueHolder.value = -1
		return

	value = DialogueDefaults.WRITE_SPEED_PRESETS[newPreset]

func _on_preset_chooser_updated_via_code(newPreset:String) -> void:
	valueHolder.get_line_edit().editable = not (
		newPreset in ["npcDefault", "inherit"]
	)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
