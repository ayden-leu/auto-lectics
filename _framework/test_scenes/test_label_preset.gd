extends Control

@onready var label:Label = $Label
@onready var chooser:OptionButton = $HBoxContainer/OptionButton
@onready var statusLabel:Label = $StatusLabel
@onready var invalidPresetButton: Button = $InvalidPresetButton

var _presets:Array[String] = []

func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("shown")
	CursorHandler.showNuclear()

	DebugHud.addChecklistEntry("The label preset test scene is visible.")
	DebugHud.addChecklistEntry("The dropdown lists all LabelSettings presets in the preset folder.")
	DebugHud.addChecklistEntry("Selecting a preset changes the visible label style.")
	DebugHud.addChecklistEntry("The status text updates when a preset is loaded.")
	DebugHud.addChecklistEntry("Test Invalid Preset button shows failure message.")

	_presets = _getFilesInPath(LabelPresetLoader.STORAGE_PATH, LabelPresetLoader.FILE_TYPE)

	if _presets.size() == 0:
		_setStatus("FAIL: No label presets found in " + LabelPresetLoader.STORAGE_PATH)
		label.text = "No label presets found."
		return

	for i in range(_presets.size()):
		_presets[i] = _presets[i].replace(LabelPresetLoader.FILE_TYPE, "")
		chooser.add_item(_presets[i])

	_updateLabelPreset(_presets[0])


func _updateLabelPreset(preset:String) -> void:
	var loadedPreset: LabelSettings = LabelPresetLoader.loadPreset(preset)

	if loadedPreset == null:
		label.label_settings = null
		label.text = "Failed to load preset: " + preset
		statusLabel.text = "PASS: Invalid preset failed safely without crashing."
		return

	label.label_settings = loadedPreset
	label.text = "Current preset: " + preset
	statusLabel.text = "PASS: Loaded preset [" + preset + "]."


func _getFilesInPath(path:String, type:String) -> Array[String]:
	var tempDirAccess:DirAccess = DirAccess.open(path)
	if not tempDirAccess:
		_setStatus("FAIL: Directory [" + path + "] does not exist.")
		return []

	tempDirAccess.list_dir_begin()

	var files:Array[String] = []
	var entryName:String = tempDirAccess.get_next()
	while entryName != "":
		if not tempDirAccess.current_is_dir() and entryName.ends_with(type):
			files.push_back(entryName)
		entryName = tempDirAccess.get_next()

	tempDirAccess.list_dir_end()

	files.sort()
	return files


func _setStatus(message:String) -> void:
	if statusLabel:
		statusLabel.text = message
	else:
		print(message)


func _on_option_button_item_selected(index:int) -> void:
	_updateLabelPreset(chooser.get_item_text(index))


func _on_invalid_preset_button_pressed() -> void:
	var loadedPreset: LabelSettings = LabelPresetLoader.loadPreset("this_preset_does_not_exist", false)

	if loadedPreset == null:
		label.label_settings = null
		label.text = "Invalid preset failed safely."
		statusLabel.text = "PASS: Invalid preset returned null without crashing."
	else:
		statusLabel.text = "FAIL: Invalid preset unexpectedly loaded."
