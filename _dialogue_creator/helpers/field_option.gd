extends Control
class_name DC_FieldOption

signal option_changed

@export var chooser:OptionButton

var valueToOptionIndex:Dictionary = {}

func fillValueToOptionIndex(referenceArray:Array, capitalize:bool = true) -> void:
	for i:int in range(referenceArray.size()):
		var value:String = referenceArray[i]
		chooser.add_item(value.capitalize() if capitalize else value)
		valueToOptionIndex.set(value, i)

func _on_chooser_updated(_index:int) -> void:
	option_changed.emit()
