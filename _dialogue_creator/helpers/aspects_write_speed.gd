extends VBoxContainer
class_name DC_AspectsWriteSpeed
## Manages the write speed aspects you can configure for [DC_DialogueNode] and [DC_OptionNode].

## The node that handles the write speed presets you can choose.
@export var presetHandler:DC_WriteSpeedPresetFieldOption
## The node that handles the write speed value you can choose.
@export var valueSetter:SpinBox

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
## # Set the aspects for some event IDs
## writeSpeedAspectsHandler.aspects = "fast"
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
## # Set the aspects for some event IDs
## writeSpeedAspectsHandler.value = 25
## [/codeblock]
var value:float:
	set(newValue):
		valueSetter.value = newValue
	get():
		return valueSetter.value

func _on_preset_changed() -> void:
	if preset == "custom":
		return
	
	value = DialogueDefaults.WRITE_SPEED_PRESETS[preset]

func _on_value_changed(newValue: float) -> void:	
	match newValue:
		DialogueDefaults.WRITE_SPEED_PRESETS.slow:
			preset = "slow"
		DialogueDefaults.WRITE_SPEED_PRESETS.medium:
			preset = "medium"
		DialogueDefaults.WRITE_SPEED_PRESETS.fast:
			preset = "fast"
		_:
			preset = "custom"
