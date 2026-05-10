@tool
extends DialogueWindow
class_name DialogueConsole
## [b]Internal-use only.[/b]  The main console-like window for interacting with
## a dialogue event.
##
## On top of the SFX events for [DialogueWindow], it comes with additional SFX events:[br]
## - text:  plays when text is being written into a log entry.[br]
## - closeReject:  plays when the DialogueConsole cannot be closed
## and something tries to close it.[br]
## - userTextAdded:  plays when player adds text to the [member _textInput].
## - userTextSubmitted:  plays when the player submits text in the [member _textInput].

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
## Emitted when the player submits text.
signal command_entered(command:String)
## [b]Internal-use only.[/b]  Used to continue logic when writing text.
signal _all_text_visible()

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
## The prefix to visually add before the user's input.
## This is just visual, so the input will not have this included.
const _INPUT_PREFIX:String = ""
## [b]Internal-use only.[/b]  A reference to a pre-set [RichTextLabel] scene.
const _LOG_ENTRY:Resource = preload(FR_Globals.SCENES.DialogueConsoleLogEntry)
## [b]Internal-use only.[/b]  A reference to a pre-set [Control] scene.
const _LOG_ENTRY_SPACER:Resource = preload(FR_Globals.SCENES.DialogueConsoleLogEntrySpacer)
## [b]Internal-use only.[/b]  A reference to a pre-set [Label] scene.
const _LOG_ID_LABEL:Resource = preload(FR_Globals.SCENES.DialogueConsoleLogEntryIdLabel)

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
## [b]Internal-use only.[/b]  The positions where options are initially spawned from.
@onready var _optionSpawnPositions:Dictionary[String, Marker2D] = {
	"left": %OptionSpawnPositions/Left,
	"right": %OptionSpawnPositions/Right
}

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The name of the [InteractableNPC] that was interacted with.
var instigatingNpc: InteractableNPC
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
## The theme variation for text that displays in the console.
## The left and right aligned text have their own entries
## via [code].left[/code] and [code].right[/code]
var themeVariation:Dictionary = {
	"left": "_defaultConsolePlayer",
	"right": "_defaultConsoleBot"
}
## The message that gets displayed if the player tries to close the console
## when they aren't able to.  Can be overwritten to be whatever you want via code.
var exitRejectMessage:String = "[Console Closure Denied]"
## The number of [DialogueWarningTileWindow]s to spawn during a hectic dialogue event.
var numHecticWarningWindows:int = 6
## If the current dialogue event has ended.
var dialogueEnded:bool = false
## If the text write on effect should be skipped or not.
var bypassTextWriting:bool = false

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
	%ContentsScroller.get_v_scroll_bar().custom_minimum_size.x = 24.0

	if Engine.is_editor_hint():
		return
	super()
	windowType = "console"

	_hecticBar.visible = false
	hecticDuration = 5.0  # TODO:  remove this when it becomes customizable

	for child in _contentsStorage.get_children():
		if child == _textInput.get_parent():
			continue

		child.queue_free()

func _process(_delta: float) -> void:
	super(_delta)
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
	dialogueEnded = false
	headerText = instigatingNpc.displayName
	FR_MenuManager.disable()

	_closeAllOptionWindows()
	_stopHecticMode()

	_textInput.text = ""
	_textInput.grab_focus()

## Starts displaying the the loaded text in [member textToAdd],
## records [member currentDialogueID] into [_dialogueHistory],
## and spawns options once complete.
func start() -> void:
	sfxPlayers.spawn.play()
	if _recordHistory:
		_dialogueHistory.push_back(currentDialogueID)
	_recordHistory = true

	# Spawn warnings before text is typed
	if mode == "hectic":
		_spawnHecticWarningWindows()
	await _addRightText(textToAdd, true)

	all_dialogue_text_visible.emit()
	await get_tree().create_timer(delayBtwnWriteDialogueAndOptions).timeout

	_spawnOptionWindows()
	all_options_available.emit()
	_forceTextInput()

	if _optionData.is_empty():
		dialogueEnded = true
		_forceTextInput()
		return

	if mode == "hectic":
		_startHecticCountdown()

## Closes this window, unless the [InteractableNPC] the player is talking to
## is in [member _NPCS_PREVENT_CLOSING].
func close() -> void:
	if instigatingNpc != null and instigatingNpc.rejectConsoleExit and not dialogueEnded:
		await _addRightText(instigatingNpc.rejectConsoleExitMessage)
		return

	if not canBeClosed:
		sfxPlayers.closeReject.play()
		await _addRightText(exitRejectMessage)
		return

	FR_MenuManager.enable()
	_stopHecticMode()
	option_chosen.emit("")  # TODO:  use the close signal instead to close this.
	super()

## Removes this from the scene.
## If you want to close this window, run [method close] instead.
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

## Adds a right text entry to the console.
## [br][br]
## [code]metadata[/code] can have the following fields:
## [codeblock]
## 	"writeSpeed":  # a float for the number of characters per second to display.
## 	"instant":  $ if the text should be displayed instantly.
## 	"theme":  # the text theme to apply to this entry.
## [/codeblock]
func addExternalEntry(message:String, metadata:Dictionary) -> void:
	var tempSpeed:float = textWriteSpeed
	var tempTheme:String = themeVariation.right
	var tempBypass:bool = bypassTextWriting

	if metadata.has("writeSpeed") and typeof(metadata.writeSpeed) == TYPE_FLOAT:
		textWriteSpeed = metadata.writeSpeed
	if metadata.has("theme") and typeof(metadata.theme) == TYPE_STRING:
		themeVariation.right = metadata.theme
	if metadata.has("instant") and typeof(metadata.instant) == TYPE_BOOL:
		bypassTextWriting = metadata.instant

	_addRightText(message)
	textWriteSpeed = tempSpeed
	themeVariation.right = tempTheme
	bypassTextWriting = tempBypass

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Creates a text entry and adds it to [member _contentsStorage].
func _createLogEntry(alignment:HorizontalAlignment, addID:bool = false) -> RichTextLabel:
	var entry:RichTextLabel = _LOG_ENTRY.instantiate()
	entry.text = ""

	# just text alignment
	#entry.horizontal_alignment = alignment
	#_contentsStorage.add_child(entry)

	# node setup alignment
	var holder:VBoxContainer = VBoxContainer.new()
	var textHolder:HBoxContainer = HBoxContainer.new()
	var spacer:Control = _LOG_ENTRY_SPACER.instantiate()
	var idLabel:Label

	if addID:
		idLabel = _LOG_ID_LABEL.instantiate()
		idLabel.text = "[ID: " + currentDialogueID + "]"
		holder.add_child(idLabel)
	holder.add_child(textHolder)
	_contentsStorage.add_child(holder)

	if alignment == HORIZONTAL_ALIGNMENT_LEFT:
		textHolder.add_child(entry)
		textHolder.add_child(spacer)
	elif alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		textHolder.add_child(spacer)
		textHolder.add_child(entry)

	_textInput.get_parent().move_to_front()

	return entry

## [b]Internal-use only.[/b]  Adds a text entry and displays it
## at [member textWriteSpeed] characters per second.
func _typeText(textToWrite:String, alignment:HorizontalAlignment, themeVar:String, addID:bool) -> void:
	_isWritingText = true

	var entry:RichTextLabel = _createLogEntry(alignment, addID)
	entry.theme_type_variation = themeVar
	entry.visible_characters = 0
	entry.text = textToWrite

	# the below snippit fixes a bug where if the text length is small enough,
	# the vertical spacing gets all weird.
	if entry.text.length() < 5:
		entry.text += "THIELF"

	var delay: float = 1.0 / max(textWriteSpeed, 0.0001)
	for _i in range(textToWrite.length()):
		if bypassTextWriting:
			entry.visible_characters = -1
			bypassTextWriting = false
			break

		entry.visible_characters += 1
		_scrollToBottom()
		if not sfxPlayers.text.playing:
			sfxPlayers.text.play()
		await get_tree().create_timer(delay, false, true).timeout
	_scrollToBottom()

	_isWritingText = false
	_all_text_visible.emit()

## [b]Internal-use only.[/b]  Adds a text entry.
func _addText(text:String, alignment:HorizontalAlignment, themeVar:String, addID:bool) -> void:
	var entry:RichTextLabel = _createLogEntry(alignment, addID)
	entry.theme_type_variation = themeVar
	entry.text = text

	# the below snippit fixes a bug where if the text length is small enough,
	# the vertical spacing gets all weird.
	if entry.text.length() < (3 + _INPUT_PREFIX.length()):
		entry.text += "THI"
		entry.visible_characters = entry.text.length() - 3

	_scrollToBottom()

## [b]Internal-use only.[/b]  Helper function to add text from the player to the console.
func _addLeftText(text:String, addID:bool = false) -> void:
	_addText(_INPUT_PREFIX + text, HORIZONTAL_ALIGNMENT_LEFT, themeVariation.left, addID)

func _addLeftTextTyping(text:String, addID:bool = false) -> void:
	_typeText(text, HORIZONTAL_ALIGNMENT_LEFT, themeVariation.left, addID)
	await _all_text_visible

## [b]Internal-use only.[/b]  Helper function to add text from a bot to the console.
func _addRightText(text:String, addID:bool = false) -> void:
	_typeText(text, HORIZONTAL_ALIGNMENT_RIGHT, themeVariation.right, addID)
	await _all_text_visible

## [b]Internal-use only.[/b]  Spawns the option windows.
func _spawnOptionWindows() -> void:
	_forceTextInput()

	var tempCounter:int = 0
	var verticalOffset:float = 0
	for optionData in _optionData:
		var optionWindow:DialogueConsoleOptionWindow = FR_WindowManager.createDialogueOptionWindow()

		optionWindow.id = tempCounter
		optionWindow.text = optionData.text
		optionWindow.themeVariation = optionData.textThemePreset
		AudioLoader.loadSfxIntoPlayers(optionData.sfx, optionWindow.sfxPlayers)
		optionWindow.data = optionData
		_setOptionWindowPosition(optionWindow, verticalOffset)
		optionWindow.option_selected.connect(_on_option_window_selected)
		optionWindow.start()

		_optionWindows.push_back(optionWindow)
		new_option_available.emit()
		tempCounter += 1
		verticalOffset += optionWindow.size.y + _OPTION_SPAWN_OFFSET

	all_options_available.emit()

func _setOptionWindowPosition(window:DialogueConsoleOptionWindow, verticalOffset:float) -> void:
	if mode == "normal":
		window.position = Vector2(0, verticalOffset)
		if not FR_WindowManager.positionOnScreen(_optionSpawnPositions.left.global_position):
			window.position += _optionSpawnPositions.right.global_position
		else:
			window.position += _optionSpawnPositions.left.global_position
	elif mode == "hectic":
		var canOverlap:Array[String] = ["warning_tile"]
		window.position = FR_WindowManager.getRandomPositionOnScreen(window.size, canOverlap)
	else:
		printerr("DialogueConsole/_setOptionWindowPosition:  Unhandled mode [" + mode + "]")

## [b]Internal-use only.[/b]  Handles logic for choosing an option.
func _chooseOption(optionData:Dictionary) -> void:
	themeVariation.left = optionData.textThemePreset
	_addLeftText(optionData.text)  # TODO:  determine how to handle no writing to console
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
	_contentsScroller.set_deferred("scroll_vertical", (
		_contentsScroller.get_v_scroll_bar().max_value
	))

## [b]Internal-use only.[/b]  Forces current selection to be on the input area.
func _forceTextInput() -> void:
	_textInput.edit()

## [b]Internal-use only.[/b]
## Spawns [member numHecticWarningWindows] [DialogueWarningTileWindow].
func _spawnHecticWarningWindows() -> void:
	for _i in range(numHecticWarningWindows):
		var newWindow:DialogueWarningTileWindow = FR_WindowManager.createDialogueWarningTileWindow()
		var newPosition:Vector2 = FR_WindowManager.getRandomPositionOnScreen(newWindow.size)
		newWindow.global_position = newPosition

## [b]Internal-use only.[/b]  Starts hectic mode.
func _startHecticCountdown() -> void:
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
	FR_WindowManager.closeAllWarningTileWindows()

func _handleCommand(command:String) -> void:
	# command is an option ID
	if command.is_valid_int():
		var id:int = int(command)
		if id >= 0 and id < _optionData.size():
			_chooseOption(_optionData[id])
			return

	# command is an option text
	for option in _optionData:
		if command.to_lower() == option.text.to_lower():
			_chooseOption(option)
			return

	# else assume its an actual command
	_addLeftText(command)
	command = command.to_lower()
	command_entered.emit(command)
	_scrollToBottom()

	# TODO:  move help text definition to [InteractableNPC]
	if command == "help":
		await _addRightText(_helpText)

	elif command == "back":
		_goBackOneDialogue()

	elif command == "exit":
		close()

	elif command.begins_with("load "):
		var nextID:String = command.replace("load ", "")
		if nextID in ["_default_dialogue", "_default_option"]:
			return
		option_chosen.emit(nextID)

## [b]Internal-use only.[/b]  Handles logic for when the [code]back[/code] command is entered.
func _goBackOneDialogue() -> void:
	if _dialogueHistory.size() <= 1:
		await _addLeftTextTyping("[No saved history]")
		return

	_dialogueHistory.pop_back()
	_recordHistory = false
	option_chosen.emit(_dialogueHistory.back())
	return

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when an option window is selected.
func _on_option_window_selected(chosenOptionWindow:DialogueConsoleOptionWindow) -> void:
	_on_input_submitted(chosenOptionWindow.text)

## [b]Internal-use only.[/b]
## Handles logic for when the text in the text input area gets updated
func _on_input_text_changed(_new_text: String) -> void:
	sfxPlayers.userTextAdded.stop()
	sfxPlayers.userTextAdded.play()
	_scrollToBottom()

## [b]Internal-use only.[/b]
## Handles logic for when text is entered into the [_textInput].
func _on_input_submitted(input: String) -> void:
	if _isWritingText:
		if input == "":
			bypassTextWriting = true
		return

	if input == "":
		return

	sfxPlayers.userTextSubmitted.stop()
	sfxPlayers.userTextSubmitted.play()
	_textInput.text = ""
	var text := input.strip_edges()
	_handleCommand(text)

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
