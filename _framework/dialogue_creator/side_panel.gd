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
	var result:Dictionary = {}
	
	if %NodeTypeChooser.chosen != DialogueDefaults.DEFAULT_DIALOGUE.type:
		result.type = %NodeTypeChooser.chosen
	if %NodeTextThemeChooser.chosen != DialogueDefaults.DEFAULT_DIALOGUE.textThemePreset:
		result.textThemePreset = %NodeTextThemeChooser.chosen
	if %NodeWriteSpeedPresetChooser.chosen != DialogueDefaults.DEFAULT_DIALOGUE.writeSpeed:
		result.writeSpeed = %NodeWriteSpeedPresetChooser.chosen
		if %NodeWriteSpeedPresetChooser.chosen == "custom" and \
			%NodeWriteSpeedValueField.value != DialogueDefaults.DEFAULT_DIALOGUE.writeSpeedCustom:
			result.writeSpeedCustom = %NodeWriteSpeedValueField.value
	if %NodeSfxAspects.configuredEvents != DialogueDefaults.DEFAULT_DIALOGUE.sfx:
		result.sfx = %NodeSfxAspects.configuredEvents
	
	return result

func loadDialogueFields(data:Dictionary) -> void:
	if data.has("type"):
		%NodeTypeChooser.chosen = data.type
	if data.has("textThemePreset"):
		%NodeTextThemeChooser.chosen = data.textThemePreset
	if data.has("writeSpeed"):
		%NodeWriteSpeedPresetChooser.chosen = data.writeSpeed
	if data.has("writeSpeedCustom"):
		%NodeWriteSpeedValueField.value = data.writeSpeedCustom
	if data.has("sfx"):
		%NodeSfxAspects.configuredEvents = data.sfx

func getOptionFields() -> Dictionary:
	var result:Dictionary = {}
	
	if %OptionTypeChooser.chosen != DialogueDefaults.DEFAULT_OPTION.type:
		result.type = %OptionTypeChooser.chosen
	if %OptionTextThemeChooser.chosen != DialogueDefaults.DEFAULT_OPTION.textThemePreset:
		result.textThemePreset = %OptionTextThemeChooser.chosen
	if %OptionWriteSpeedPresetChooser.chosen != DialogueDefaults.DEFAULT_OPTION.writeSpeed:
		result.writeSpeed = %OptionWriteSpeedPresetChooser.chosen
		if %OptionWriteSpeedPresetChooser.chosen == "custom" and \
			%OptionWriteSpeedValueField.value != DialogueDefaults.DEFAULT_OPTION.writeSpeedCustom:
			result.writeSpeedCustom = %OptionWriteSpeedValueField.value
	if %OptionSfxAspects.configuredEvents != DialogueDefaults.DEFAULT_OPTION.sfx:
		result.sfx = %OptionSfxAspects.configuredEvents
	if %OptionSpawnDelayField.value != DialogueDefaults.DEFAULT_OPTION.spawnDelay:
		result.spawnDelay = %OptionSpawnDelayField.value
	if %OptionLifetimeField.value != DialogueDefaults.DEFAULT_OPTION.lifetime:
		result.lifetime = %OptionLifetimeField.value
	
	return result

func loadOptionFields(data:Dictionary) -> void:
	if data.has("type"):
		%OptionTypeChooser.chosen = data.type
	if data.has("textThemePreset"):
		%OptionTextThemeChooser.chosen = data.textThemePreset
	if data.has("writeSpeed"):
		%OptionWriteSpeedPresetChooser.chosen = data.writeSpeed
	if data.has("writeSpeedCustom"):
		%OptionWriteSpeedValueField.value = data.writeSpeedCustom
	if data.has("sfx"):
		%OptionSfxAspects.configuredEvents = data.sfx
	if data.has("spawnDelay"):
		%OptionSpawnDelayField.value = data.spawnDelay
	if data.has("lifetime"):
		%OptionLifetimeField.value = data.lifetime

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
