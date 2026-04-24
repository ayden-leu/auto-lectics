@tool
extends DialogueWindow
class_name DialogueConsole
## [b]Internal-use only.[/b]  The main console-like window for interacting with
## a dialogue event.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when an option is chosen.
signal option_chosen(nextID:String)
## Emitted when all dialogue for a dialogue tree node is visible.
signal all_dialogue_text_visible()
## Emitted when a new dialogue option is visible.
signal new_option_available()
## Emitted when all dialogue options is visible.
signal all_options_available()
## [b]Internal-use only.[/b]  Used to continue logic when writing text.
signal _all_text_visible()

## Emitted when the open_gate command is entered.
signal open_gate

# ------------------------------------------------
# enums
# ------------------------------------------------
## [b]Internal-use only.[/b]  Used for referencing which corner of the
## [DialogueConsoleWindow] to start spawning options from.
enum _OptionAnchor {
	TOP_LEFT,    ## Options are right-aligned and appear on the top-left corner.
	TOP_RIGHT,   ## Options are left-aligned and appear on the top-right corner.
	BOTTOM_LEFT, ## Options are right-aligned and appear on the bottom-left corner.
	BOTTOM_RIGHT ## Options are left-aligned and appear on the bottom-right corner.
}

# ------------------------------------------------
# constants
# ------------------------------------------------
## How far each spawned option should be from each other, vertically.
const _OPTION_SPAWN_OFFSET:int = 3
## [b]Internal-use only.[/b]  A reference to a pre-set [RichTextLabel] scene.
const _LOG_ENTRY:Resource = preload(FR_Globals.SCENES.DialogueConsoleLogEntry)
## [b]Internal-use only.[/b]  A reference to a pre-set [Control] scene.
const _LOG_ENTRY_SPACER:Resource = preload(FR_Globals.SCENES.DialogueConsoleLogEntrySpacer)

## @deprecated
## [b]Internal-use only.[/b]  A list of [InteractableNPC]s that make it so
## you cannot close this window.
var _NPCS_PREVENT_CLOSING:Array[String] = [  # TODO:  make this a boolean varaible that is set by InteractableNPC
	"dropPod", "The Office"
]
# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The area where the player can enter text.
@onready var _textInput: LineEdit = %ConsoleInput
## [b]Internal-use only.[/b]  The thing that allows you to scroll through the console's contents.
@onready var _contentsScroller: ScrollContainer = %ContentsScroller
## [b]Internal-use only.[/b]  The node that holds all of the console's text contents.
@onready var _contentsStorage:VBoxContainer = %DialogueLogStorage
## [b]Internal-use only.[/b]  The progress bar that displays how much time is left
## until a hectic dialogue event ends.
@onready var _hecticBar:ProgressBar = %HecticBar
## [b]Internal-use only.[/b]  The hectic dialogue event timer.
@onready var _hecticTimer: Timer = %HecticTimer
## [b]Internal-use only.[/b]  The position where options are initially spawned from.
@onready var _optionSpawnPosition:Marker2D = %OptionSpawnPosition
## Holds the AudioStreamPlayers for each event.
@onready var _sfxPlayer:Dictionary[String, AudioStreamPlayer] = {
	"spawn": %SFX/spawn,
	"text": %SFX/text
}

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The name of the [InteractableNPC] that was interacted with.
var nameOfNpcTalkingTo:String = ""
## The text to add to the [member _contents].
var textToAdd:String = ""
## How fast dialogue characters are "written," in characters per second.
var textWriteSpeed:float = DialogueDefaults.WRITE_SPEED_PRESETS.medium
## The ID of the current dialogue file that is loaded.
var currentDialogueID:String = ""
## The delay between the dialogue finishing being displayed and spawning the options, in seconds.
var delayBtwnWriteDialogueAndOptions: float = 0.5
## The dialogue mode this console is currently in.
## Refer to [member DialogueDefaults.DIALOGUE_MODES] for valid modes.
var mode:String = "normal"
## The dialogue ID to load when a hectic dialogue event is failed.
var hecticFailureDialogueID:String = ""
## How long a hectic dialogue event lasts.
var hecticDuration:float = 5.0:  # TODO  make this customizable
	set(newDuration):
		hecticDuration = newDuration
		_hecticBar.max_value = newDuration

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  The data of each option the player can pick from.
var _optionData:Array = []
## [b]Internal-use only.[/b]  The windows that represent each option a player can pick from.
var _optionWindows:Array = []
## [b]Internal-use only.[/b]  IS true when the dialogue text is still being typed.
var _isWritingText:bool = false
## [b]Internal-use only.[/b]  Stores previously loaded dialogue IDs.
## The ID at the end of the array is the currently loaded dialogue.
var _dialogueHistory:Array[String] = []
## [b]Internal-use only.[/b]  Whether the dialogue IDs loaded get recorded
## into [member _dialogueHistory].  Gets set to true whenever the console
## is prepared.
var _recordHistory:bool = true
## [b]Internal-use only.[/b]  True when the hectic dialgoue event timer is running.
var _hecticCountdownActive: bool = false
## Show this message when "help" is inputted
var _helpText: String = \
		"Here are the commands:\n\n" + \
		"0, 1, 2...  =  choose an option by ID \n\n(you can also type out the text but that would take forever)\n\n" + \
		"back        =  reverse one dialog\n\n (feel free to use this if the AI's are getting argumentative, they're coded to respect the command) \n\n" + \
		"exit        =  close the console"

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	
	_center()
	_hecticBar.visible = false
	hecticDuration = 5.0  # TODO:  remove this when it becomes customizable
	
	for child in _contentsStorage.get_children():
		child.queue_free()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if _hecticCountdownActive:
		_hecticBar.value = _hecticTimer.time_left

func _gui_input(event: InputEvent) -> void:
	super(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Prepares the [DialogueConsole] by setting up initial defaults.
func prepare() -> void:
	headerText = nameOfNpcTalkingTo
	
	_closeAllOptionWindows()
	_stopHecticMode()
	
	_textInput.text = ""
	_textInput.grab_focus()

## Starts displaying the the loaded text in [member textToAdd],
## records [member currentDialogueID] into [_dialogueHistory],
## and spawns options once complete.
func start() -> void:
	_sfxPlayer.spawn.play()
	if _recordHistory:
		_dialogueHistory.push_back(currentDialogueID)
	_recordHistory = true
	await _addBotText(textToAdd)

	all_dialogue_text_visible.emit()	
	await get_tree().create_timer(delayBtwnWriteDialogueAndOptions).timeout
	
	_spawnOptionWindows()
	all_options_available.emit()
	_forceTextInput()
	
	if mode == "hectic":
		_startHecticMode()

## Closes this window, unless the [InteractableNPC] the player is talking to
## is in [member _NPCS_PREVENT_CLOSING].
func close() -> void:
	if nameOfNpcTalkingTo in _NPCS_PREVENT_CLOSING:
		await _addBotText("[Console Closure Denied].")
		return
	
	option_chosen.emit("")  # TODO:  use the close signal instead to close this.
	super()

## Removes this from the scene.
func kill() -> void:
	_stopHecticMode()
	_closeAllOptionWindows()
	_dialogueHistory.clear()
	queue_free()

## Loads the data of all posible options for this dialogue object.
## Also sorts the options from shortest to longest spawn delay.
func loadOptionData(options:Array) -> void:
	_optionData.clear()
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			printerr("DialogueConsole: Data for this entry is not a Dictionary.")
			print("Entry data: ", option)
			continue
		
		if StoryFlags.flagsMatch(option.checkFlags):
			_optionData.push_back(option)

	_optionData.sort_custom(func(a, b): return a.spawnDelay < b.spawnDelay)

## Loads the SFX event players with an audio ID, if given.
func loadSfx(sfxEventsToLoad:Dictionary) -> void:
	for eventID in _sfxPlayer.keys():
		_sfxPlayer[eventID].stop()
		AudioLoader.clearAudioRandomizer(_sfxPlayer[eventID].stream)
		AudioLoader.loadSfxFromId(sfxEventsToLoad[eventID], _sfxPlayer[eventID].stream)

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Creates a text entry and adds it to [member _contentsStorage].
func _createLogEntry(alignment:HorizontalAlignment) -> RichTextLabel:
	var entry:RichTextLabel = _LOG_ENTRY.instantiate()
	entry.text = ""
	
	# just text alignment
	#entry.horizontal_alignment = alignment
	#_contentsStorage.add_child(entry)
	
	# node setup alignment
	var holder:HBoxContainer = HBoxContainer.new()
	var spacer:Control = _LOG_ENTRY_SPACER.instantiate()
	_contentsStorage.add_child(holder)
	
	if alignment == HORIZONTAL_ALIGNMENT_LEFT:
		holder.add_child(entry)
		holder.add_child(spacer)
	elif alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		holder.add_child(spacer)
		holder.add_child(entry)
	
	return entry

## [b]Internal-use only.[/b]  Adds a text entry and displays it
## at [member textWriteSpeed] characters per second.
func _typeText(textToWrite:String, alignment:HorizontalAlignment, themeVariation:String) -> void:
	_isWritingText = true
	
	var entry:RichTextLabel = _createLogEntry(alignment)
	entry.theme_type_variation = themeVariation
	entry.visible_characters = 0
	entry.text = textToWrite
	
	var delay: float = 1.0 / max(textWriteSpeed, 0.0001)	
	for _i in range(textToWrite.length()):
		entry.visible_characters += 1
		_scrollToBottom()
		if not _sfxPlayer.text.playing:
			_sfxPlayer.text.play()
		await get_tree().create_timer(delay).timeout
	_scrollToBottom()
	
	_isWritingText = false
	_all_text_visible.emit()

## [b]Internal-use only.[/b]  Adds a text entry.
func _addText(text:String, alignment:HorizontalAlignment, themeVariation:String) -> void:
	var entry:RichTextLabel = _createLogEntry(alignment)
	entry.theme_type_variation = themeVariation
	entry.text = text
	_scrollToBottom()

## [b]Internal-use only.[/b]  Helper function to add text from the player to the console.
func _addPlayerText(text:String) -> void:	
	_addText(text, HORIZONTAL_ALIGNMENT_LEFT, "RichTextLabelPlayer")

func _addPlayerTextTyping(text:String) -> void:
	_typeText(text, HORIZONTAL_ALIGNMENT_LEFT, "RichTextLabelPlayer")
	await _all_text_visible

## [b]Internal-use only.[/b]  Helper function to add text from a bot to the console.
func _addBotText(text:String) -> void:
	_typeText(text, HORIZONTAL_ALIGNMENT_RIGHT, "RichTextLabelBot")
	await _all_text_visible

## [b]Internal-use only.[/b]  Spawns the option windows.
func _spawnOptionWindows() -> void:
	_forceTextInput()
	
	var tempCounter:int = 0
	var verticalOffset:float = 0
	for optionData in _optionData:
		var optionWindow = FR_WindowManager.createDialogueOptionWindow()
		
		optionWindow.id = tempCounter
		optionWindow.text = optionData.text
		optionWindow.data = optionData
		optionWindow.position = _optionSpawnPosition.global_position + Vector2(0, verticalOffset)
		optionWindow.option_selected.connect(_on_option_window_selected)
		
		_optionWindows.push_back(optionWindow)
		new_option_available.emit()
		tempCounter += 1
		verticalOffset += optionWindow.size.y + _OPTION_SPAWN_OFFSET
	
	all_options_available.emit()

## [b]Internal-use only.[/b]  Handles logic for choosing an option.
func _chooseOption(optionData:Dictionary) -> void:
	_addPlayerText(optionData.text)  # TODO:  determine how to handle no writing to console
	_stopHecticMode()
	_closeAllOptionWindows()
	StoryFlags.updateFlags(optionData.setFlags)
	option_chosen.emit(optionData.nextID)

## [b]Internal-use only.[/b]  Forcebilly closes all spawned option windows.
func _closeAllOptionWindows() -> void:
	for optionWindow in _optionWindows:
		optionWindow.close()
	_optionWindows.clear()
	
## [b]Internal-use only.[/b]  Forces the scroll bar to be moved to the bottom.
func _scrollToBottom() -> void:
	await get_tree().process_frame
	_contentsScroller.scroll_vertical = int(
		_contentsScroller.get_v_scroll_bar().max_value
	)

## [b]Internal-use only.[/b]  Forces current selection to be on the input area.
func _forceTextInput() -> void:
	_textInput.edit()

## [b]Internal-use only.[/b]  Starts hectic mode.
func _startHecticMode() -> void:
	_hecticCountdownActive = true
	_hecticBar.visible = true
	_hecticBar.value = INF
	_hecticTimer.start(hecticDuration)

## [b]Internal-use only.[/b]  Stops hectic mode.
func _stopHecticMode() -> void:
	_hecticCountdownActive = false
	_hecticBar.visible = false
	_hecticBar.value = INF
	_hecticTimer.stop()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when an option window is selected.
func _on_option_window_selected(chosenOptionWindow:DialogueConsoleOptionWindow) -> void:
	_chooseOption(chosenOptionWindow.data)

## [b]Internal-use only.[/b]  Handles logic for when text is entered into the [_textInput].
func _on_input_submitted(raw_text: String) -> void:
	if _isWritingText:
		return
	var text := raw_text.strip_edges()
	_textInput.text = ""
	
	if text.to_lower() == "help":
		_addPlayerText(text)
		await _addBotText(_helpText)
		return
	
	if text.to_lower() == "back":
		_addPlayerText(text)
		_on_console_request_back()
		return
	
	if text.to_lower() == "exit":
		_addPlayerText(text)
		close()
		return
	
	if text.to_lower() == "open_gate" && nameOfNpcTalkingTo == "mini-BOSS":
		_addPlayerText(text)
		open_gate.emit()
		return
	
	if text.is_valid_int():
		var idx := int(text)
		if idx >= 0 and idx < _optionData.size():
			_chooseOption(_optionData[idx])
			return
	
	for opt in _optionData:
		if text.to_lower() == str(opt.get("text", "")).to_lower():
			_chooseOption(opt)
			return

## [b]Internal-use only.[/b]  Handles logic for when the [code]back[/code] command is entered.
func _on_console_request_back() -> void:
	if _dialogueHistory.size() <= 1:
		await _addPlayerTextTyping("[no recorded history in log]")
		return
	
	_dialogueHistory.pop_back()
	_recordHistory = false
	option_chosen.emit(_dialogueHistory.back())
	return

## [b]Internal-use only.[/b]  Handles logic for when the hectic timer times out.
func _on_hectic_timer_timeout() -> void:
	if not _hecticCountdownActive:
		return

	_stopHecticMode()
	_closeAllOptionWindows()
	
	if hecticFailureDialogueID == "":
		printerr("DialogueConsole:  nextOnHecticFailureID not set for ", currentDialogueID)

	option_chosen.emit(hecticFailureDialogueID)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	return super()

func _validate_property(property: Dictionary) -> void:
	super(property)
