extends DC_FieldOption
class_name DC_TypeFieldOption

enum VALID_TYPES {
	DIALOGUE,
	OPTION
}

@export var type:VALID_TYPES

var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
	get():
		if type == VALID_TYPES.DIALOGUE:
			return DialogueDefaults.DIALOGUE_TYPES[chooser.selected]
		elif type == VALID_TYPES.OPTION:
			return DialogueDefaults.OPTION_TYPES[chooser.selected]
		printerr("field_option_type: Unhandled option type: ", type)
		return "error"

func _ready() -> void:
	if type == VALID_TYPES.DIALOGUE:
		fillValueToOptionIndex(DialogueDefaults.DIALOGUE_TYPES)
	elif type == VALID_TYPES.OPTION:
		fillValueToOptionIndex(DialogueDefaults.OPTION_TYPES)
	
	option = DialogueDefaults.DEFAULT_DIALOGUE.type
