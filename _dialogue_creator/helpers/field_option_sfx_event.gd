extends DC_FieldOption
class_name DC_SfxEventFieldOption

@export var label:Label

var sfxIDs:Array[String] = ["none", "inherit"]
var eventID:String = "":
	set(value):
		eventID = value
		label.text = value.capitalize()
var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
	get():
		return sfxIDs[chooser.selected]

func _ready() -> void:
	sfxIDs.append_array(DirAccess.get_directories_at(Globals.STORAGE_PATH.SFX))
	fillValueToOptionIndex(sfxIDs, false)
