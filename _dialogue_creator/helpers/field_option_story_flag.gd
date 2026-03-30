extends DC_FieldOption
class_name DC_StoryFlagFieldOption

signal removing(field:DC_StoryFlagFieldOption)
signal updating(oldFlagID:String, newFlagID:String)

@export var toggler:CheckBox

var _prevSelectedFlagID:String
var mySeparator:VSeparator
var flagID:String:
	set(newID):
		chooser.selected = valueToOptionIndex[newID]
		_prevSelectedFlagID = newID
	get():
		if chooser.selected != -1:
			return chooser.get_item_text(chooser.selected)
		return ""
var enabled:bool:
	set(newState):
		toggler.button_pressed = newState
	get():
		return toggler.button_pressed

func _on_remove_button_pressed() -> void:
	removing.emit(self)
	mySeparator.queue_free()
	queue_free()

func _on_update_available_flags(availableFlags:Array) -> void:
	var tempCopy:Array = availableFlags.duplicate()
	if flagID:
		tempCopy.push_front(flagID)
	
	valueToOptionIndex = {}
	for _i in range(chooser.item_count):
		chooser.remove_item(0)
	fillValueToOptionIndex(tempCopy, false)

func _on_chooser_updated(_index:int) -> void:
	updating.emit(_prevSelectedFlagID, flagID)
	_prevSelectedFlagID = flagID
	
	super(_index)

func _on_checkbox_clicked() -> void:
	option_changed.emit()
