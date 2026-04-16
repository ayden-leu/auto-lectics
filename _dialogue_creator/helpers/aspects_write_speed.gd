extends VBoxContainer
class_name DC_AspectsWriteSpeed
## [b]Internal-use only.[/b]  Manages the write speed aspects you can configure for [DC_DialogueNode] and [DC_OptionNode].

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted whenever the value of a [DC_SfxEventFieldOption] field gets updated.
signal value_changed()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The node that handles the write speed presets you can choose.
@export var presetHandler:DC_WriteSpeedPresetFieldOption
## The node that handles the write speed value you can choose.
@export var valueSetter:SpinBox

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Used to get and set the write speed preset for this [DC_DialogueNode] or [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## [br][br]
## Usage:
## [codeblock]
## var writeSpeedAspectsHandler:DC_AspectsWriteSpeed = # a pre-configured node from the scene tree
##
## # Get the currently selected write speed preset
## print(writeSpeedAspectsHandler.preset)  # output: "medium"
## 
## # Set the write speed preset
## writeSpeedAspectsHandler.preset = "fast"
## [/codeblock]
var preset:String:
	set(newPreset):
		presetHandler.option = newPreset
	get():
		return presetHandler.option

## Used to get and set the write speed preset for this [DC_DialogueNode] or [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## [br][br]
## Usage:
## [codeblock]
## var writeSpeedAspectsHandler:DC_AspectsWriteSpeed = # a pre-configured node from the scene tree
##
## # Get the currently set write speed
## print(writeSpeedAspectsHandler.value)  # output: 60
## 
## # Set the write speed value
## writeSpeedAspectsHandler.value = 25
## [/codeblock]
var value:float:
	set(newValue):
		valueSetter.value = newValue
	get():
		return valueSetter.value

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Updates the current write speed value based on the
## current value of [member preset].
func _updateWriteSpeedValueFromPreset() -> void:
	if preset == "custom":
		return
	
	value = DialogueDefaults.WRITE_SPEED_PRESETS[preset]
	value_changed.emit()

## [b]Internal-use only.[/b]  Updates the current write speed preset based on the
## current value of [member value].
func _updateWriteSpeedPresetFromValue() -> void:
	match value:
		DialogueDefaults.WRITE_SPEED_PRESETS.slow:
			preset = "slow"
		DialogueDefaults.WRITE_SPEED_PRESETS.medium:
			preset = "medium"
		DialogueDefaults.WRITE_SPEED_PRESETS.fast:
			preset = "fast"
		_:
			preset = "custom"
	value_changed.emit()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when the write speed preset is updated.
func _on_preset_changed() -> void:
	_updateWriteSpeedValueFromPreset()

## [b]Internal-use only.[/b]  Runs when the write speed value is updated.
func _on_value_changed(_newValue: float) -> void:	
	_updateWriteSpeedPresetFromValue()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
