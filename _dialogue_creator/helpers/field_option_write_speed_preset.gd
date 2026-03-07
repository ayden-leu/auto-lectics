extends DC_FieldOption
class_name DC_WriteSpeedPresetFieldOption

var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
		option_changed.emit()
	get():
		return DialogueDefaults.WRITE_SPEED_PRESETS.keys()[chooser.selected]

func _ready() -> void:
	fillValueToOptionIndex(DialogueDefaults.WRITE_SPEED_PRESETS.keys())
	
	option = DialogueDefaults.defaultDialogue.writeSpeed

func _on_item_selected(_index: int) -> void:
	option = option
