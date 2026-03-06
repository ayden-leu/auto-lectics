extends DC_FieldOption
class_name DC_TypeFieldOption

var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
	get():
		return DialogueDefaults.DIALOGUE_TYPES[chooser.selected]

func _ready() -> void:
	fillValueToOptionIndex(DialogueDefaults.DIALOGUE_TYPES)
