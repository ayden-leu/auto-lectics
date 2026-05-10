extends Control

@onready var label:Label = $Label
@onready var chooser:OptionButton = $HBoxContainer/OptionButton

func _ready() -> void:
	var presets:Array[String] = _getFilesInPath(FR_Globals.STORAGE_PATH.LABEL_PRESETS, FR_Globals.LABEL_PRESET_FILE_TYPE)
	if presets.size() == 0:
		printerr("Oops! No presets.")

	for i in range(presets.size()):
		presets[i] = presets[i].replace(".tres", "")
		chooser.add_item(presets[i])
	_updateLabelPreset(presets[0])

func _updateLabelPreset(preset:String) -> void:
	label.label_settings = LabelPresetLoader.loadPreset(preset)

func _getFilesInPath(path:String, type:String) -> Array[String]:
	var tempDirAccess:DirAccess = DirAccess.open(path)
	if not tempDirAccess:
		printerr("Directory [", path, "] does not exist.")
	tempDirAccess.list_dir_begin()

	var files:Array[String]
	var entryName:String = tempDirAccess.get_next()
	while entryName != "":
		if not tempDirAccess.current_is_dir() and entryName.ends_with(type):
			files.push_back(entryName)
		entryName = tempDirAccess.get_next()

	files.sort()
	return files


func _on_option_button_item_selected(index:int) -> void:
	_updateLabelPreset(chooser.get_item_text(index))
