extends Control

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
@export var contents:TabContainer

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[b]  If the side panel is expanded or not.
var expanded:bool = false:
	set(state):
		expanded = state
		if state:
			_expand()
		else:
			_contract()

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	expanded = false
	
	%NodeTypeField.type = DialogueDefaults.DEFAULT_DIALOGUE.type
	%NodeTextThemeField.textTheme = DialogueDefaults.DEFAULT_DIALOGUE.textThemePreset
	%NodeSfxAspects.aspects = DialogueDefaults.DEFAULT_DIALOGUE.sfx
	
	%OptionTypeField.type = DialogueDefaults.DEFAULT_OPTION.type
	%OptionTextThemeField.textTheme = DialogueDefaults.DEFAULT_OPTION.textThemePreset
	%OptionSfxAspects.aspects = DialogueDefaults.DEFAULT_OPTION.sfx

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
func getDialogueFields() -> Dictionary:
	return {
		"type": %NodeTypeField.option,
		"textThemePreset": %NodeTextThemeField.textTheme,
		"writeSpeed": %NodeWriteSpeedAspects.preset,
		"writeSpeedCustom": %NodeWriteSpeedAspects.value,
		"sfx": %NodeSfxAspects.aspects
	}

func getOptionFields() -> Dictionary:
	return{
		# === Optional ===
		"type": %OptionTypeField.option,
		"textThemePreset": %OptionTextThemeField.textTheme,
		"writeSpeed": %OptionWriteSpeedAspects.preset,
		"writeSpeedCustom": %OptionWriteSpeedAspects.value,
		"sfx": %OptionSfxAspects.aspects,
		"spawnDelay": %OptionSpawnDelayField.value,
		"lifetime": %OptionLifetimeField.value
	}

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _expand() -> void:
	contents.visible = true

func _contract() -> void:
	contents.visible = false

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------

func _on_toggler_pressed() -> void:
	expanded = !expanded
