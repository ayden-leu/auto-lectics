extends HBoxContainer
class_name DC_SfxEvent

@export var label:Label
@export var chooser:OptionButton

var eventID:String = "":
	set(value):
		eventID = value
		label.text = value.capitalize()

func _ready() -> void:
	fillOptions()
	
func fillOptions() -> void:
	var ids:PackedStringArray = DirAccess.get_directories_at(Globals.STORAGE_PATH.SFX)
	for id in ids:
		chooser.add_item(id)

func getChosenOption() -> String:
	return chooser.get_item_text(chooser.selected).to_lower()
