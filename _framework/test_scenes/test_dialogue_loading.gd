extends Control

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
const FILE_EXTENSION:String = ".json"

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
@onready var fieldNPC:OptionButton = %NpcField
@onready var fieldFile:OptionButton = %FileField
@onready var labelDialogueText:Label = %DialogueText
@onready var labelDialogueMode:Label = %DialogueMode
@onready var labelDialogueHecticFailID:Label = %DialogueHecticFailID
@onready var labelDialogueHecticDuration: Label = %DialogueHecticDuration
@onready var labelDialogueOptionCount: Label = %DialogueOptionCount
@onready var labelDialogueTextTheme:Label = %DialogueTextTheme
@onready var labelDialogueType:Label = %DialogueType
@onready var labelDialogueWriteSpeedPreset:Label = %DialogueWriteSpeedPreset
@onready var labelDialogueWriteSpeedValue:Label = %DialogueWriteSpeedValue
@onready var labelDialogueBackgroundTheme:Label = %DialogueBackgroundTheme
@onready var labelDialogueSfxEventSpawn:Label = %DialogueSfxEventSpawn
@onready var labelDialogueSfxEventText:Label = %DialogueSfxEventText

@onready var fieldOption:OptionButton = %OptionField
@onready var labelOptionText:Label = %OptionText
@onready var labelOptionNextID:Label = %OptionNextID
@onready var labelOptionTextTheme:Label = %OptionTextTheme
@onready var labelOptionType:Label = %OptionType
@onready var labelOptionWriteSpeedPreset:Label = %OptionWriteSpeedPreset
@onready var labelOptionWriteSpeedValue:Label = %OptionWriteSpeedValue
@onready var labelOptionBackgroundTheme:Label = %OptionBackgroundTheme
@onready var labelOptionSpawnDelay:Label = %OptionSpawnDelay
@onready var labelOptionLifetime:Label = %OptionLifetime
@onready var labelOptionSfxEventSpawn:Label = %OptionSfxEventSpawn
@onready var labelOptionSfxEventText:Label = %OptionSfxEventText
@onready var labelOptionCheckFlags: Label = %OptionCheckFlags
@onready var labelOptionSetFlags: Label = %OptionSetFlags
@onready var labelOptionAllowBack: Label = %OptionAllowBack
@onready var labelOptionRejectBackMessage: Label = %OptionRejectBackMessage

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
var _optionData:Array[Dictionary] = []

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("shown")
	CursorHandler.showNuclear()

	_loadOptionButtonOptions(
		fieldNPC,
		_getFoldersInPath(DialogueLoader.STORAGE_PATH)
	)
	_on_npc_field_item_selected(fieldNPC.selected)

#func _process(delta: float) -> void:
	#super(delta)  # needed if inheriting a custom class with its own _process().  Will run the inherited class' _process() function.

#func _physics_process(delta: float) -> void:
	#super(delta)  # needed if inheriting a custom class with its own _physics_process().  Will run the inherited class' _physics_process() function.

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _getFoldersInPath(path:String) -> Array[String]:
	var tempDirAccess:DirAccess = DirAccess.open(path)
	if not tempDirAccess:
		printerr("Directory [", path, "] does not exist.")
	tempDirAccess.list_dir_begin()

	var directories:Array[String]
	var entryName:String = tempDirAccess.get_next()
	while entryName != "":
		if tempDirAccess.current_is_dir():
			directories.push_back(entryName)
		entryName = tempDirAccess.get_next()

	return directories

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


func _getFilesInPathRecursive(path: String, type: String, relativePrefix: String = "") -> Array[String]:
	var tempDirAccess: DirAccess = DirAccess.open(path)
	if not tempDirAccess:
		printerr("Directory [", path, "] does not exist.")
		return []
	
	var files: Array[String] = []
	
	tempDirAccess.list_dir_begin()
	var entryName: String = tempDirAccess.get_next()
	
	while entryName != "":
		if entryName.begins_with("."):
			entryName = tempDirAccess.get_next()
			continue
		
		var fullPath: String = path.path_join(entryName)
		var relativePath: String = relativePrefix.path_join(entryName) if relativePrefix != "" else entryName
		
		if tempDirAccess.current_is_dir():
			files.append_array(_getFilesInPathRecursive(fullPath, type, relativePath))
		elif entryName.ends_with(type):
			files.push_back(relativePath)
		
		entryName = tempDirAccess.get_next()
	
	tempDirAccess.list_dir_end()
	files.sort()
	return files


func _loadOptionButtonOptions(button:OptionButton, options:Array[String]) -> void:
	for option in options:
		button.add_item(option)
	button.selected = 0


func _clearOptionButtonOptions(button:OptionButton) -> void:
	for _i in range(button.item_count):
		button.remove_item(0)

func _loadDialogueFile() -> void:
	var topFolder: String = fieldNPC.get_item_text(fieldNPC.selected)
	var selectedRelativeFile: String = fieldFile.get_item_text(fieldFile.selected)
	var fileFolder: String = selectedRelativeFile.get_base_dir()
	var fileName: String = selectedRelativeFile.get_file()
	var dialogueID: String = fileName.trim_suffix(FILE_EXTENSION)
	var entityName: String = topFolder
	if fileFolder != "":
		entityName = topFolder.path_join(fileFolder)
	var data: Dictionary = DialogueLoader.getDialogueNode(entityName, dialogueID)
	
	if data.is_empty():
		labelDialogueText.text = "[ERROR: Failed to load dialogue file]"
		return
	
	labelDialogueText.text = str(data.get("text", ""))
	labelDialogueMode.text = str(data.get("mode", ""))
	labelDialogueHecticFailID.text = str(data.get("nextOnHecticFailureID", ""))
	labelDialogueHecticDuration.text = str(data.get("hecticDuration", "N/A"))
	labelDialogueOptionCount.text = str(data.get("options", []).size())
	labelDialogueTextTheme.text = str(data.get("textThemePreset", ""))
	labelDialogueType.text = str(data.get("type", ""))
	labelDialogueWriteSpeedPreset.text = str(data.get("writeSpeed", ""))
	labelDialogueWriteSpeedValue.text = str(data.get("writeSpeedCustom", ""))
	labelDialogueBackgroundTheme.text = str(data.get("backgroundTheme", "N/A"))
	var sfx: Dictionary = data.get("sfx", {})
	labelDialogueSfxEventSpawn.text = str(sfx.get("spawn", ""))
	labelDialogueSfxEventText.text = str(sfx.get("text", ""))
	_clearOptionButtonOptions(fieldOption)
	_optionData = []
	
	var optionNames: Array[String] = []
	for option in data.get("options", []):
		if typeof(option) != TYPE_DICTIONARY:
			continue
		
		_optionData.push_back(option)
		
		var optionText: String = str(option.get("text", ""))
		if optionText.strip_edges() == "":
			optionText = "[continue / empty option]"
		
		optionNames.push_back(optionText)
	
	if not optionNames.is_empty():
		_loadOptionButtonOptions(fieldOption, optionNames)


func _loadOption() -> void:
	if _optionData.is_empty():
		return
	
	if fieldOption.selected < 0 or fieldOption.selected >= _optionData.size():
		return
	
	var data:Dictionary = _optionData[fieldOption.selected]
	
	labelOptionText.text = str(data.get("text", ""))
	labelOptionNextID.text = str(data.get("nextID", ""))
	labelOptionTextTheme.text = str(data.get("textThemePreset", ""))
	labelOptionType.text = str(data.get("type", ""))
	labelOptionWriteSpeedPreset.text = str(data.get("writeSpeed", ""))
	labelOptionWriteSpeedValue.text = str(data.get("writeSpeedCustom", ""))
	labelOptionBackgroundTheme.text = str(data.get("backgroundTheme", "N/A"))
	labelOptionSpawnDelay.text = str(data.get("spawnDelay", ""))
	labelOptionLifetime.text = str(data.get("lifetime", ""))
	labelOptionCheckFlags.text = str(data.get("checkFlags", {}))
	labelOptionSetFlags.text = str(data.get("setFlags", {}))
	labelOptionAllowBack.text = str(data.get("allowBack", true))
	labelOptionRejectBackMessage.text = str(data.get("rejectBackMessage", "N/A"))
	
	var sfx:Dictionary = data.get("sfx", {})
	labelOptionSfxEventSpawn.text = str(sfx.get("spawn", ""))
	labelOptionSfxEventText.text = str(sfx.get("text", ""))
	
	print("checkFlags:")
	print(data.get("checkFlags", {}))
	print("setFlags")
	print(data.get("setFlags", {}))

	# TODO:  particles

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_npc_field_item_selected(index: int) -> void:
	_clearOptionButtonOptions(fieldFile)
	_clearOptionButtonOptions(fieldOption)
	_optionData = []

	var selectedFolder:String = fieldNPC.get_item_text(index)
	_loadOptionButtonOptions(
		fieldFile,
		_getFilesInPathRecursive(
			DialogueLoader.STORAGE_PATH.path_join(selectedFolder),
			FILE_EXTENSION
		)
	)

func _on_file_field_item_selected(_index: int) -> void:
	_clearOptionButtonOptions(fieldOption)
	_optionData = []

func _on_load_button_pressed() -> void:
	_loadDialogueFile()
	if _optionData != []:
		_loadOption()

func _on_option_field_item_selected(_index: int) -> void:
	_loadOption()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
