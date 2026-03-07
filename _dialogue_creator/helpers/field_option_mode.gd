extends DC_FieldOption
class_name DC_ModeFieldOption

signal set_hectic_port(on:bool)

@export var hecticPortLabel:Label

var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
		_on_item_selected(valueToOptionIndex[newOption])
	get():
		return DialogueDefaults.DIALOGUE_MODES[chooser.selected]

func _ready() -> void:
	fillValueToOptionIndex(DialogueDefaults.DIALOGUE_MODES)
	hecticPortLabel.visible = false
	
	option = DialogueDefaults.defaultDialogue.mode

func enableHecticPort() -> void:
	_on_item_selected(valueToOptionIndex.hectic)

func _on_item_selected(index: int) -> void:
	var isHectic:bool = (DialogueDefaults.DIALOGUE_MODES[index] == "hectic")
	
	hecticPortLabel.visible = isHectic
	set_hectic_port.emit(isHectic)
