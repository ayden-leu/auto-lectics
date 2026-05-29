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

func _loadOptionButtonOptions(button:OptionButton, options:Array[String]) -> void:
	for option in options:
		button.add_item(option)
	button.selected = 0

func _clearOptionButtonOptions(button:OptionButton) -> void:
	for _i in range(button.item_count):
		button.remove_item(0)

func _loadDialogueFile() -> void:
	var path:String = DialogueLoader.STORAGE_PATH + "/" + \
			fieldNPC.get_item_text(fieldNPC.selected) + "/" + \
			fieldFile.get_item_text(fieldFile.selected)

	var data:Dictionary = DialogueLoader.loadDialogueNodeFile(path)
	labelDialogueText.text = data.text
	labelDialogueMode.text = data.mode
	labelDialogueHecticFailID.text = data.nextOnHecticFailureID
	labelDialogueTextTheme.text = data.textThemePreset
	labelDialogueType.text = data.type
	labelDialogueWriteSpeedPreset.text = data.writeSpeed
	labelDialogueWriteSpeedValue.text = str(data.writeSpeedCustom)
	labelDialogueBackgroundTheme.text = data.backgroundTheme

	labelDialogueSfxEventSpawn.text = data.sfx.spawn
	labelDialogueSfxEventText.text = data.sfx.text

	_optionData = []
	var hashtagMyText:Array[String] = []
	for option in data.options:
		_optionData.push_back(option)
		hashtagMyText.push_back(option.text)

	if hashtagMyText != []:
		_loadOptionButtonOptions(fieldOption, hashtagMyText)

func _loadOption() -> void:
	var data:Dictionary = _optionData[fieldOption.selected]

	labelOptionText.text = data.text
	labelOptionNextID.text = data.nextID
	labelOptionTextTheme.text = data.textThemePreset
	labelOptionType.text = data.type
	labelOptionWriteSpeedPreset.text = data.writeSpeed
	labelOptionWriteSpeedValue.text = str(data.writeSpeedCustom)
	labelOptionBackgroundTheme.text = data.backgroundTheme
	labelOptionSpawnDelay.text = str(data.spawnDelay)
	labelOptionLifetime.text = str(data.lifetime)

	labelOptionSfxEventSpawn.text = data.sfx.spawn
	labelOptionSfxEventText.text = data.sfx.text

	print("checkFlags:")
	print(data.checkFlags)
	print("setFlags")
	print(data.setFlags)

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
		_getFilesInPath(
			DialogueLoader.STORAGE_PATH + "/" + selectedFolder,
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
