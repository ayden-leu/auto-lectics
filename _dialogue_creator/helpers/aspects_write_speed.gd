extends VBoxContainer
class_name DC_AspectsWriteSpeed

@export var presetHandler:DC_WriteSpeedPresetFieldOption
@export var valueSetter:SpinBox

var preset:String:
	set(newPreset):
		presetHandler.option = newPreset
	get():
		return presetHandler.option
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
