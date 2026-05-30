extends Node
## Test scene for [VocalDialoguePlayer]
##
## Lets user test [VocalDialoguePlayer]'s functionalities in an isolated environment.

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
@onready var _treeIdField: OptionButton = %TreeIdField
@onready var _nodeIdField:OptionButton = %NodeIdField
#@onready var _loadDialogueNodeButton:Button = %LoadDialogueNode
#@onready var _playerEnabledToggler:CheckBox = %PlayerEnabledToggle
@onready var _vocalDialoguePlayer:VocalDialoguePlayer = %VocalDialoguePlayer
@onready var _middleLabel: Label = %MiddleLabel

@onready var _delayAmountLabel: Label = %DelayAmount
@onready var _currentSubtitles: Label = %CurrentSubtitles
@onready var _currentDialogueID: Label = %CurrentDialogueID
@onready var _nextDialogueID: Label = %NextDialogueID
@onready var _canContinue: CheckBox = %CanContinue

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	FR_MenuManager.disable() # either enable() or disable()
	FR_WindowManager.disable() # either enable() or disable()
	CursorHandler.setDefault("shown") # refer to documentation or hover over the function for valid values
	CursorHandler.showNuclear()	 # either hideNuclear() or showNuclear()

	_loadOptionButtonOptions(
		_treeIdField,
		_getFoldersInPath(VocalDialoguePlayer.STORAGE_PATH)
	)
	call_deferred("_on_tree_id_field_item_selected", _treeIdField.selected)

	_updateMiddleLabel()

	DebugHud.addChecklistEntry("Doesn't do anything when disabled")

	DebugHud.addChecklistEntry("Loads initial dialogue")
	DebugHud.addChecklistEntry("Initial sound file plays")
	DebugHud.addChecklistEntry("Initial subtitles display")
	DebugHud.addChecklistEntry("Initial delay works")

	DebugHud.addChecklistEntry("Can continue to the next dialogue")
	DebugHud.addChecklistEntry("Loads next dialogue")
	DebugHud.addChecklistEntry("Next sound file plays")
	DebugHud.addChecklistEntry("Next subtitles display")
	DebugHud.addChecklistEntry("Next delay works")

	DebugHud.addChecklistEntry("Ending the dialogue doesn't crash the game")

	DebugHud.addChecklistEntry("Subtitles can fade")

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _getFoldersInPath(path:String) -> Array[String]:
	var tempDirAccess:DirAccess = DirAccess.open(path)
	if not tempDirAccess:
		DebugHud.addToLog("Directory [" + path + "] does not exist.", DebugHud.LogType.ERROR)
	tempDirAccess.list_dir_begin()

	var directories:Array[String]
	var entryName:String = tempDirAccess.get_next()
	while entryName != "":
		if tempDirAccess.current_is_dir():
			directories.push_back(entryName)
		entryName = tempDirAccess.get_next()

	directories.sort()
	return directories

func _getFilesInPath(path:String, type:String, blacklist:Array[String] = []) -> Array[String]:
	var tempDirAccess:DirAccess = DirAccess.open(path)
	if not tempDirAccess:
		printerr("Directory [", path, "] does not exist.")
	tempDirAccess.list_dir_begin()

	var files:Array[String]
	var entryName:String = tempDirAccess.get_next()
	while entryName != "":
		if not tempDirAccess.current_is_dir() and entryName.ends_with(type) and entryName not in blacklist:
			files.push_back(entryName.replace(type, ""))
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

func _updateMiddleLabel() -> void:
	if not _vocalDialoguePlayer.enabled:
		_middleLabel.text = "VocalDialoguePlayer not enabled."
	elif _vocalDialoguePlayer.currentDialogueID == "":
		_middleLabel.text = "VocalDialoguePlayer data not loaded."
	else:
		_middleLabel.text = "Press the interact button to start."

func _updatePlayerStats() -> void:
	_delayAmountLabel.text = str(_vocalDialoguePlayer._delayBeforeAllowContinue)
	_currentSubtitles.text = _vocalDialoguePlayer.subtitles.text
	_currentDialogueID.text = _vocalDialoguePlayer.currentDialogueID
	_nextDialogueID.text = _vocalDialoguePlayer._nextDialogueID

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_tree_id_field_item_selected(index:int) -> void:
	_clearOptionButtonOptions(_nodeIdField)
	_loadOptionButtonOptions(
		_nodeIdField,
		_getFilesInPath(
			VocalDialoguePlayer.STORAGE_PATH + _treeIdField.get_item_text(index), VocalDialoguePlayer.DIALOGUE_FILE_EXTENSION,
			[VocalDialoguePlayer.DEFAULTS_FILE_NAME + VocalDialoguePlayer.DIALOGUE_FILE_EXTENSION]
		)
	)

func _on_player_enabled_toggle_toggled(toggled_on:bool) -> void:
	_vocalDialoguePlayer.enabled = toggled_on
	_updateMiddleLabel()

func _on_load_dialogue_node_pressed() -> void:
	_vocalDialoguePlayer.dialogueTreeID = _treeIdField.get_item_text(_treeIdField.selected)
	_vocalDialoguePlayer.initialDialogueID = _nodeIdField.get_item_text(_nodeIdField.selected)
	_vocalDialoguePlayer._ready()
	_vocalDialoguePlayer._canContinue = true
	_updateMiddleLabel()

func _on_fade_enabled_toggle_toggled(toggled_on:bool) -> void:
	_vocalDialoguePlayer.fadeSubtitles = toggled_on

func _on_vocal_dialogue_player_dialogue_advanced() -> void:
	await get_tree().process_frame
	_updatePlayerStats()

func _on_vocal_dialogue_player_dialogue_finished() -> void:
	await get_tree().process_frame
	_updatePlayerStats()

func _on_vocal_dialogue_player_can_contine(state: bool) -> void:
	_canContinue.button_pressed = state
