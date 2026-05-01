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
	
	%NodeTypeChooser.chosen = DialogueDefaults.DEFAULT_DIALOGUE.type
	%NodeTextThemeChooser.chosen = DialogueDefaults.DEFAULT_DIALOGUE.textThemePreset
	%NodeWriteSpeedPresetChooser.chosen = DialogueDefaults.DEFAULT_DIALOGUE.writeSpeed
	%NodeWriteSpeedValueField.value = DialogueDefaults.DEFAULT_DIALOGUE.writeSpeedCustom
	%NodeSfxAspects.configuredEvents = DialogueDefaults.DEFAULT_DIALOGUE.sfx
	
	%OptionTypeChooser.chosen = DialogueDefaults.DEFAULT_OPTION.type
	%OptionSpawnDelayField.value = DialogueDefaults.DEFAULT_OPTION.spawnDelay
	%OptionLifetimeField.value = DialogueDefaults.DEFAULT_OPTION.lifetime
	%OptionWriteSpeedPresetChooser.chosen = DialogueDefaults.DEFAULT_OPTION.writeSpeed
	%OptionWriteSpeedValueField.value = DialogueDefaults.DEFAULT_OPTION.writeSpeedCustom	
	%OptionTextThemeChooser.chosen = DialogueDefaults.DEFAULT_OPTION.textThemePreset
	%OptionSfxAspects.configuredEvents = DialogueDefaults.DEFAULT_OPTION.sfx

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
func getDialogueFields() -> Dictionary:
	return {
		"type": %NodeTypeChooser.chosen,
		"textThemePreset": %NodeTextThemeChooser.chosen,
		"writeSpeed": %NodeWriteSpeedPresetChooser.chosen,
		"writeSpeedCustom": %NodeWriteSpeedValueField.value,
		"sfx": %NodeSfxAspects.configuredEvents
	}

func getOptionFields() -> Dictionary:
	return{
		"type": %OptionTypeChooser.chosen,
		"textThemePreset": %OptionTextThemeChooser.chosen,
		"writeSpeed": %OptionWriteSpeedPresetChooser.chosen,
		"writeSpeedCustom": %OptionWriteSpeedValueField.value,
		"sfx": %OptionSfxAspects.configuredEvents,
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
