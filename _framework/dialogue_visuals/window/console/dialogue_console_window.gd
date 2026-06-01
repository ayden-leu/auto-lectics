@tool
extends DialogueWindow
class_name DialogueConsole
## The main console-like window for interacting with dialogue events.
##
## Shouldn't be spawned directly.
## Is mainly spawned by [InteractableNPC]s via [WindowManager].
## [br][br]
## It can do everything [DialogueWindow] can in addition to everything below.
##
##
##
## [br][br][br]
## [b]Setup Brief:[/b][br]
## The contents of this DialogueConsole is assembled like the following:
## [codeblock lang=text]
## DialogueLogStorage (referenced with _contentsStorage)
## ├── VboxContainer (text on the left side)
## │   └── HBoxContainer
## │       ├── DialogueLogEntry
## │       └── Spacer
## ├── VboxContainer (text on the right side)
## │   ├── DialogueIdLabel
## │   └── HBoxContainer
## │       ├── Spacer
## │       └── DialogueLogEntry
## └── InputArea
##     ├── Label
##     └── ConsoleInput (referenced with _textInput)
## [/codeblock]
## The [member _contentsStorage] node is a child of [member _contentsScroller].
## [br][br]
## [param DialogueLogEntry] is a pre-configured [RichTextLabel].  It has BBCode enabled,
## letting you apply fancy effects to the text.  Refer to the online documentation
## for "BBCode in RichTextLabel" to learn what effects you can apply out-of-the-box.
## It is also configured to always have its contents visible, meaning there won't
## be a small scroll bar to the right of it.
## [br][br]
## [param Spacer] is just used for positioning [param DialogueLogEntry].
## Both [param DialogueLogEntry] and [param Spacer]'s [member Control.visible ratio] field
## are set to [code]7.0[/code] and [code]3.0][/code] respectively.
## Having the [param Spacer] be above the [param DialogueLogEntry] makes the text
## align to the right positionally, while having it below does it to the left.
## [br][br]
## The [param InputArea] is set to shrink to the end and expand vertically, making it
## always at the bottom of the window.
##
##
##
## [br][br][br]
## [b]Dialogue Event:[/b][br]
## When an [InteractableNPC] starts a dialogue event, any dialogue related to it
## gets loaded into various [param DialogueLogEntry] entries, matching the
## setup above.
## Refer to the documentation for [InteractableNPC] to see what it does to DialogueConsole.
## The [InteractableNPC] that started it is also saved to [member instigatingNpc].
## [br][br]
## When [DialogueConsoleOptionWindow]s are spawned via [method _spawnOptionWindows],
## their position gets set by [method _setOptionWindowPosition].
## It will choose to spawn them to the left of the DialogueConsole initially, but
## if that position would be off screen, it spawns them to the right.
## [br][br]
## During a hectic dialogue event, [member numHecticWarningWindows] amount of
## [DialogueWarningTileWindow]s will be spawned.
## These won't cover any existing [DialogueWindow]s.  The position is determined
## by [method WindowManager.getRandomPositionOnScreen]. A bar representing
## how long the hectic event lasts will also be displayed above the DialogueConsole.
## [br][br]
## When an option is chosen, there will be a delay that lasts [member optionChooseDelay] seconds.
## [br][br]
## If a chosen option is configured to not allow the [code]back[/code] command,
## the dialogue node that spawned the option will be added to [member dialogueNodeBackBlacklist]
## and the rejection message will be added to [member dialogueNodeBackRejectMessages].
## This will also set [member allowLoad] to [code]false[/code].
## [br][br]
## The IDs of all dialogue nodes loaded for this dialogue event are added to
## [member _dialogueHistory].
## The ID of currently loaded dialogue node is the last entry, which should
## match [member currentDialogueID].
##
##
##
## [br][br][br]
## [b]Commands:[/b][br]
## Any text submitted to the console is considered a "command."
## Below are the commands that this DialogueConsole can handle:
## [br][br]
## - [code][any number][/code]:  During a dialogue event, this will choose any displayed
## [DialogueConsoleOptionWindow]s and advance the dialogue.
## [br][br]
## - [code]back[/code]:  During a dialogue event, this will load the previously
## loaded dialogue node.
## If there are none, it displays a message in the console saying there is nothing to load.
## If the dialogue node to load is within [member dialogueNodeBackBlacklist],
## its corresponding rejection message in [member dialogueNodeBackRejectMessages]
## will be displayed and the dialogue node won't be loaded.
## [br][br]
## - [code]load [ID][/code]:  Loads a dialogue node with the given ID.
## If [member allowLoad] is [code]false[/code], [member rejectLoadMessage] is displayed
## in the console.  If the ID is invalid, nothing happens.
## [br][br]
## - [code]clear[/code]:  Clears the DialogueConsole's contents.
## [br][br]
## - [code]repeat_msg[/code]:  Readds [member textToAdd] to the DialogueConsole.
## [br][br]
## - [code]exit[/code]:  Closes the DialogueConsole.
## [br][br]
## - [code]help[/code]:  Displays a help message explaining the above commands.
## [br][br]
## All entered commands for this dialogue event are added to [member _commandHistory].
## Players can go through their previous commands by pressing the [kbd]UP[/kbd]
## and [kbd]DOWN[/kbd] key.
## [br][br]
## If a node subscribes to the DialogueConsole through [WindowManager], they'll be able
## to listen to these commands and do whatever in response to them, like pushing
## a message to the DialogueConsole.  Refer to the documentation for [WindowManager]
## to see how to do that.
##
##
##
## [br][br][br]
## [b]WindowManager:[/b][br]
## [WindowManager] is the "middleman" for interacting with the DialogueConsole.
## Refer to its documentation if you want to do things with the DialogueConsole.
##
##
##
## [br][br][br]
## [b]SFX Events:[/b][br]
## On top of the SFX events for [DialogueWindow], it comes with the following optional SFX events:
## [br]
## - [code]closeReject[/code]:  plays when the DialogueConsole cannot be closed
## and something tries to close it.
## [br]
## - [code]userTextAdded[/code]:  plays when player adds text to the [member _textInput].
## [br]
## - [code]userTextSubmitted[/code]:  plays when the player submits text in the [member _textInput].
## [br][br]
## There are also SFX events for dialogue console text being written and the DialogueConsole
## spawning, but those are configured by the dialogue node that gets loaded during a dialogue event.
##
##
##
## [br][br][br]
## [b]Styling:[/b][br]
## The theme settings for the DialogueConsole are in the same resource where all
## of the [DialogueWindow] theme settings are defined.  DialogueConsole specific
## entries have "Console" in their name. (e.g LabelHeaderConsole).
##
##
## [br][br][br]
## [b]Other notes:[/b][br]
## If [member canBeClosed] is [code]false[/code], [member exitRejectMessage] will
## be displayed in the console.
## [br][br]
## If you happen to see "THI" or "THIELF" in a DialogueConsole entry,
## then something went wrong because you aren't supposed to see that.
## It's just padding text to fix a vertical alignment issue.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when an option is chosen.
## [param nextID] is the ID of the next dialogue node to load.
signal option_chosen(nextID:String)
## Emitted when all dialogue for a dialogue tree node is visible.
signal all_dialogue_text_visible()
## Emitted when a new dialogue option is visible.
signal new_option_available()
## Emitted when all dialogue options is visible.
signal all_options_available()
## Emitted when the player submits text.
## [param command] is the text the player submitted.
signal command_entered(command:String)
## [b]Internal-use only.[/b]
## Used to continue logic when writing text.
signal _all_text_visible()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]
## How far each spawned option should be from each other, vertically.
const _OPTION_SPAWN_OFFSET:int = 3
## [b]Internal-use only.[/b]
## The prefix to visually add before the user's input.
## This is just visual, so the input will not have this included.
const _INPUT_PREFIX:String = ""
## [b]Internal-use only.[/b]
## A reference to a pre-set [RichTextLabel] scene.
const _LOG_ENTRY:Resource = preload("uid://1n8yvdu14dcd")
## [b]Internal-use only.[/b]
## A reference to a pre-set [Control] scene.
const _LOG_ENTRY_SPACER:Resource = preload("uid://2pbfftop6j5e")
## [b]Internal-use only.[/b]
## A reference to a pre-set [Label] scene.
const _LOG_ID_LABEL:Resource = preload("uid://cdt7ouilmdwo0")
## [b]Internal-use only.[/b]
## The delay between spawning [DialogueWarningTile]s.
const _HECTIC_WARNING_SPAWN_DELAY:float = 0.01

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The delay between choosing an option and acting on it, in seconds.
@export var optionChooseDelay:float = 0.2

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The area where the player can enter text.
@onready var _textInput:LineEdit = %ConsoleInput
## [b]Internal-use only.[/b]
## The thing that allows you to scroll through the console's contents.
@onready var _contentsScroller:ScrollContainer = %ContentsScroller
## [b]Internal-use only.[/b]
## The node that holds all of the console's text contents.
@onready var _contentsStorage:VBoxContainer = %DialogueLogStorage
## [b]Internal-use only.[/b]
## The progress bar that displays how much time is left
## until a hectic dialogue event ends.
@onready var _hecticBar:ProgressBar = %HecticBar
## [b]Internal-use only.[/b]
## The hectic dialogue event timer.
@onready var _hecticTimer:Timer = %HecticTimer
## [b]Internal-use only.[/b]
## The positions where options are initially spawned from.
@onready var _optionSpawnPositions:Dictionary[String, Marker2D] = {
	"left": %OptionSpawnPositions/Left,
	"right": %OptionSpawnPositions/Right
}
## The SFX event players that are manually set outside of [SfxEventHandler].
## [br]
## Currently, it has [param spawn] and [param text], which are customized by [InteractableNPC]
## when it loads in a dialogue node.
@onready var sfxPlayers:Dictionary[String, AudioStreamPlayer] = {
	"spawn": %sfxSpawn,
	"text": %sfxText
}

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The name of the [InteractableNPC] that was interacted with.
var instigatingNpc:InteractableNPC
## The text to add to [member _contents].
var textToAdd:String = ""
## How fast dialogue characters are "written," in characters per second.
var textWriteSpeed:float = DialogueDefaults.WRITE_SPEED_PRESETS.medium
## The ID of the current dialogue file that is loaded.
var currentDialogueID:String = ""
## The delay between the dialogue finishing being displayed and spawning the options, in seconds.
var delayBtwnWriteDialogueAndOptions:float = 0.5
## The dialogue mode this console is currently in.
## Refer to [member DialogueDefaults.DIALOGUE_MODES] for valid modes.
var mode:String = "normal"
## The dialogue ID to load when a hectic dialogue event is failed.
var hecticFailureDialogueID:String = ""
## How long a hectic dialogue event lasts.
var hecticDuration:float = 5.0:
	set(newDuration):
		hecticDuration = newDuration
		_hecticBar.max_value = newDuration
## The theme variation for text that displays in the console.
## The left and right aligned text have their own entries
## via [param .left] and [param .right].
var themeVariation:Dictionary = {
	"left": "_defaultConsolePlayer",
	"right": "_defaultConsoleBot"
}
## A list of dialogue node IDs that cannot be loaded when entering the [code]back[/code] command.
var dialogueNodeBackBlacklist:Array[String] = []
## Maps dialogue node IDs to the message displayed when the [code]back[/code] command is denied.
var dialogueNodeBackRejectMessages:Dictionary = {}
## Whether the [code]load[/code] command is enabled or not.
var allowLoad:bool = true
## The message that gets displayed when trying to run the [code]load[/code] command
## while [member allowLoad] is [code]false[/code].
## Can be overwritten to be whatever you want via code.
var rejectLoadMessage:String = "[Load Command Disabled]"
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
## [b]Internal-use only.[/b]
## The data of each option the player can pick from.
var _optionData:Array = []
## [b]Internal-use only.[/b]
## The windows that represent each option a player can pick from.
var _optionWindows:Array[DialogueConsoleOptionWindow] = []
## [b]Internal-use only.[/b]
## Is true when the dialogue text is still being typed.
var _isWritingText:bool = false
## [b]Internal-use only.[/b]
## Stores previously loaded dialogue IDs.
## The ID at the end of the array is the currently loaded dialogue.
var _dialogueHistory:Array[String] = []
## [b]Internal-use only.[/b]
## Keeps a record of every command entered into the console.
var _commandHistory:Array[String] = []
## [b]Internal-use only.[/b]
## The current index of history we're looking at.
var _commandHistoryIndex:int = 0
## [b]Internal-use only.[/b]
## Whether the dialogue IDs loaded get recorded into [member _dialogueHistory].
## Gets set to true whenever the console is prepared.
var _recordHistory:bool = true
## [b]Internal-use only.[/b]
## True when the hectic dialgoue event timer is running.
var _hecticCountdownActive:bool = false
## [b]Internal-use only.[/b]
## The message that gets displayed when the [code]help[/code] command is entered.
var _helpText:String = \
		"Here are the commands:\n\n" + \
		"0, 1, 2...  =  choose an option by ID \n\n(you can also type out the text but that would take forever)\n\n" + \
		"back        =  load the previous dialogue\n\n (feel free to use this if the bots are getting argumentative, they're coded to respect the command)\n\n" + \
		"load [ID]   =  loads the dialogue associated with the ID" + \
		"clear       =  clear the console" + \
		"repeat_msg  =  repeats the last message" + \
		"exit        =  close the console\n\n" + \
		"help        =  displays this message"

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	# set scrollbar size because it cant be done through the editor
	%ContentsScroller.get_v_scroll_bar().custom_minimum_size.x = 24.0

	if Engine.is_editor_hint():
		return
	super()
	windowType = "console"

	# setup initial styling stuff
	_hecticBar.visible = false
	for child in _contentsStorage.get_children():
		if child == _textInput.get_parent():
			continue
		child.queue_free()

func _process(_delta:float) -> void:
	super(_delta)
	if Engine.is_editor_hint():
		return

	if _hecticCountdownActive:
		_hecticBar.value = _hecticTimer.time_left

func _gui_input(event:InputEvent) -> void:
	super(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Prepares the [DialogueConsole] by setting up initial data.
## Ran whenever a new dialogue node is loaded.
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
## Hectic mode visuals are also shown during this.
func start() -> void:
	sfxPlayers.spawn.stop()
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
	move_to_front()
	_forceTextInput()

	if _optionData.is_empty():
		dialogueEnded = true
		_forceTextInput()
		return

	if mode == "hectic":
		_startHecticCountdown()

## Closes this window, unless the [member instigatingNpc]'s
## [member InteractableNPC.rejectConsoleExit] is [code]true[/code].
func close() -> void:
	if instigatingNpc != null and instigatingNpc.rejectConsoleExit and not dialogueEnded:
		sfxEventHandler.play("closeReject")
		await _addRightText(instigatingNpc.rejectConsoleExitMessage)
		return

	if not canBeClosed:
		sfxEventHandler.play("closeReject")
		await _addRightText(exitRejectMessage)
		return

	DebugHud.addToLog("Preparing to close DialogueConsole.")
	FR_MenuManager.enable()
	_stopHecticMode()
	_closeAllOptionWindows()

	var sfxPlayer:AudioStreamPlayer = sfxEventHandler.getPlayerForEvent("close")
	if sfxPlayer and sfxEventHandler.sfxIds.get("close", "") != "":
		sfxEventHandler.play("close")
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		hide()
		await sfxPlayer.finished

	super()

## Removes this from the scene.
## If you want to close this window, run [method close] instead.
func kill() -> void:
	DebugHud.addToLog("Killing DialogueConsole")
	_stopHecticMode()
	_closeAllOptionWindows()
	#_dialogueHistory.clear()
	#dialogueNodeBackBlacklist.clear()
	#dialogueNodeBackRejectMessages.clear()
	#allowLoad = true
	super()

## Loads the data of all posible options for this dialogue object.
## Also sorts the options from shortest to longest spawn delay.
func loadOptionData(options:Array) -> void:
	_optionData.clear()
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			DebugHud.addToLog("DialogueConsole: Data for this option is not a Dictionary.  It is a [" + type_string(typeof(option)) + "]", DebugHud.LogType.ERROR)
			continue

		if StoryFlags.flagsMatch(option.checkFlags):
			_optionData.push_back(option)

	_optionData.sort_custom(func(a, b): return a.get("spawnDelay", 0.0) <= b.get("spawnDelay", 0.0))

## Adds a right text entry to the console.
## [br][br]
## [param metadata] can have the following fields:
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
## [b]Internal-use only.[/b]
## Creates a text entry and adds it to [member _contentsStorage].
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

## [b]Internal-use only.[/b]
## Adds a text entry and displays it at [member textWriteSpeed] characters per second.
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

	var delay:float = 1.0 / max(textWriteSpeed, 0.0001)
	for _i in range(textToWrite.length()):
		if bypassTextWriting:
			entry.visible_characters = -1
			bypassTextWriting = false
			break

		entry.visible_characters += 1
		_scrollToBottom()
		if not sfxPlayers.text.playing:
			sfxPlayers.text.stop()
			sfxPlayers.text.play()
		await get_tree().create_timer(delay, false, true).timeout
	_scrollToBottom()

	_isWritingText = false
	_all_text_visible.emit()

## [b]Internal-use only.[/b]
## Adds a text entry.
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

## [b]Internal-use only.[/b]
## Helper function to add text from the player to the console.
func _addLeftText(text:String, addID:bool = false) -> void:
	_addText(_INPUT_PREFIX + text, HORIZONTAL_ALIGNMENT_LEFT, themeVariation.left, addID)

## [b]Internal-use only.[/b]
## Helper function to add text from the player to the console
## with a typing effect.
func _addLeftTextTyping(text:String, addID:bool = false) -> void:
	_typeText(text, HORIZONTAL_ALIGNMENT_LEFT, themeVariation.left, addID)
	await _all_text_visible

## [b]Internal-use only.[/b]
## Helper function to add text from a bot to the console.
## Applies a typing effect to the text.
func _addRightText(text:String, addID:bool = false) -> void:
	_typeText(text, HORIZONTAL_ALIGNMENT_RIGHT, themeVariation.right, addID)
	await _all_text_visible

## [b]Internal-use only.[/b]
## Spawns the option windows.
func _spawnOptionWindows() -> void:
	_forceTextInput()

	var tempCounter:int = 0
	var verticalOffset:float = 0
	for optionData in _optionData:
		var optionWindow:DialogueConsoleOptionWindow = FR_WindowManager.createDialogueOptionWindow()

		optionWindow.id = tempCounter
		optionWindow.text = optionData.text
		optionWindow.themeVariation = optionData.textThemePreset
		optionWindow.spawnDelay = optionData.spawnDelay
		optionWindow.lifetime = optionData.lifetime
		AudioLoader.loadSfxIntoPlayers(optionData.sfx, optionWindow.sfxPlayers)
		_setOptionWindowPosition(optionWindow, verticalOffset)
		optionWindow.option_selected.connect(_on_option_window_selected)
		optionWindow.enabled.connect(_on_option_window_enabled)
		optionWindow.disabled.connect(_on_option_window_disabled)
		optionWindow.start()
		optionData.disabled = false

		_optionWindows.push_back(optionWindow)
		new_option_available.emit()
		tempCounter += 1
		verticalOffset += optionWindow.size.y + _OPTION_SPAWN_OFFSET

	all_options_available.emit()

## [b]Internal-use only.[/b]
## Updates the given option window's position.
func _setOptionWindowPosition(window:DialogueConsoleOptionWindow, verticalOffset:float = 0) -> void:
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
		DebugHud.addToLog("DialogueConsole:  Unhandled mode [" + mode + "] when setting option window position.", DebugHud.LogType.ERROR)

## [b]Internal-use only.[/b]
## Handles logic for choosing an option.
func _chooseOption(optionData:Dictionary) -> void:
	themeVariation.left = optionData.textThemePreset
	_addLeftText(optionData.text)  # TODO:  determine how to handle no writing to console
	_stopHecticMode()
	_closeAllOptionWindows()
	StoryFlags.updateFlags(optionData.setFlags)

	# if allowBack is false, add the option to the blacklist
	if not optionData.allowBack:
		DebugHud.addToLog("DialogueConsole:  back command blocked.")
		if not dialogueNodeBackBlacklist.has(currentDialogueID):
			dialogueNodeBackBlacklist.append(currentDialogueID)
			# First time allowBack is false, disable load command too
			allowLoad = false
		dialogueNodeBackRejectMessages[currentDialogueID] = optionData.rejectBackMessage

	await get_tree().create_timer(optionChooseDelay).timeout
	option_chosen.emit(optionData.nextID)

## [b]Internal-use only.[/b]
## Forcebilly closes all spawned option windows.
func _closeAllOptionWindows() -> void:
	for optionWindow in _optionWindows:
		optionWindow.close()
	_optionWindows.clear()

## [b]Internal-use only.[/b]
## Forces the scroll bar to be moved to the bottom.
func _scrollToBottom() -> void:
	await get_tree().process_frame
	_contentsScroller.set_deferred("scroll_vertical", (
		_contentsScroller.get_v_scroll_bar().max_value
	))

## [b]Internal-use only.[/b]
## Forces current selection to be on the input area.
func _forceTextInput() -> void:
	_textInput.edit()

## [b]Internal-use only.[/b]
## Spawns [member numHecticWarningWindows] [DialogueWarningTileWindow].
func _spawnHecticWarningWindows() -> void:
	for _i in range(numHecticWarningWindows):
		var newWindow:DialogueWarningTileWindow = FR_WindowManager.createDialogueWarningTileWindow()
		var newPosition:Vector2 = FR_WindowManager.getRandomPositionOnScreen(newWindow.size)
		newWindow.global_position = newPosition
		await get_tree().create_timer(_HECTIC_WARNING_SPAWN_DELAY).timeout

## [b]Internal-use only.[/b]
## Starts hectic mode.
func _startHecticCountdown() -> void:
	_hecticCountdownActive = true
	_hecticBar.visible = true
	_hecticBar.value = INF
	_hecticTimer.start(hecticDuration)

## [b]Internal-use only.[/b]
## Stops hectic mode.
func _stopHecticMode() -> void:
	_hecticCountdownActive = false
	_hecticBar.visible = false
	_hecticBar.value = INF
	_hecticTimer.stop()
	FR_WindowManager.closeAllWarningTileWindows()

## [b]Internal-use only.[/b]
## Handles the command entered by the player.
func _handleCommand(command:String) -> void:
	# command is an option ID
	if command.is_valid_int():
		var id:int = int(command)
		if id >= 0 and id < _optionData.size():
			var data:Dictionary = _optionData[id]
			if not data.disabled:
				_chooseOption(data)
				return

	# command is an option text
	for option in _optionData:
		if command.to_lower() == option.text.to_lower() and not option.disabled:
			_chooseOption(option)
			return

	# else assume its an actual command
	_addLeftText(command)
	command = command.to_lower()
	command_entered.emit(command)
	_scrollToBottom()

	if command == "clear":
		_clearConsole()

	elif command == "help":
		await _addRightText(_helpText)

	elif command == "back":
		_goBackOneDialogue()

	elif command == "exit":
		close()

	elif command.begins_with("load "):
		if not allowLoad:
			await _addRightText(rejectLoadMessage)
			return

		var nextID:String = command.replace("load ", "")
		if nextID in ["_default_dialogue", "_default_option"]:
			return
		option_chosen.emit(nextID)

	elif command == "repeat_msg":
		_recordHistory = false
		_addRightText(textToAdd, true)
		_recordHistory = true

## [b]Internal-use only.[/b]
## Clear the console
func _clearConsole() -> void:
	for child in _contentsStorage.get_children():
		if child == _textInput.get_parent():
			continue
		child.queue_free()

## [b]Internal-use only.[/b]
## Handles logic for when the [code]back[/code] command is entered.
func _goBackOneDialogue() -> void:
	if _dialogueHistory.size() <= 1:
		await _addLeftTextTyping("[No saved history]")
		return

	var targetID:String = _dialogueHistory[_dialogueHistory.size() - 2]
	# Check if the dialogue being returned to is blacklisted
	if dialogueNodeBackBlacklist.has(targetID):
		var rejectMessage:String = dialogueNodeBackRejectMessages[targetID]
		await _addRightText(rejectMessage)
		return

	_dialogueHistory.pop_back()
	_recordHistory = false
	option_chosen.emit(targetID)

## [b]Internal-use only.[/b]
## Loads a command from [member _commandHisory] into [member _textInput].
func _loadCommandHistory(index:int) -> void:
	if _commandHistory.size() <= 0:
		DebugHud.addToLog("DialougeConsole:  No history to load.")
		return

	if index < 0:
		DebugHud.addToLog("DialogueConsole:  Hit the end of the console's history.")
		return

	# branch essentially occurs when down is pressed
	# and the loaded history is the most recent one
	if index >= _commandHistory.size():
		_textInput.text = ""
		_commandHistoryIndex = _commandHistory.size()
		return

	_commandHistoryIndex = index
	_textInput.text = _commandHistory[index]
	_textInput.caret_column = _textInput.text.length()

	get_viewport().set_input_as_handled()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when an option window is selected.
func _on_option_window_selected(chosenOptionWindow:DialogueConsoleOptionWindow) -> void:
	_on_input_submitted(chosenOptionWindow.text)

## [b]Internal-use only.[/b]
## Handles logic for when a [DialogueConsoleOptionWindow] enables itself.
func _on_option_window_enabled(dataIndex:int) -> void:
	_optionData[dataIndex].disabled = false

## [b]Internal-use only.[/b]
## Handles logic for when a [DialogueConsoleOptionWindow] disables itself.
func _on_option_window_disabled(dataIndex:int) -> void:
	_optionData[dataIndex].disabled = true

## [b]Internal-use only.[/b]
## Handles logic for when the text in the text input area gets updated
func _on_input_text_changed(_new_text:String) -> void:
	sfxEventHandler.play("userTextAdded")
	_scrollToBottom()

## [b]Internal-use only.[/b]
## Handles logic for when text is entered into the [_textInput].
func _on_input_submitted(input:String) -> void:
	if _isWritingText:
		if input == "":
			bypassTextWriting = true
		return

	if input == "":
		return

	sfxEventHandler.play("userTextSubmitted")
	_textInput.text = ""
	var text := input.strip_edges()

	_commandHistory.push_back(text)
	_commandHistoryIndex = _commandHistory.size()

	_handleCommand(text)

## [b]Internal-use only.[/b]
## Handles logic for when text is entered into the [_textInput].
func _on_console_input_gui_input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_UP:
			_loadCommandHistory(_commandHistoryIndex - 1)

		elif event.keycode == KEY_DOWN:
			_loadCommandHistory(_commandHistoryIndex + 1)

## [b]Internal-use only.[/b]
## Handles logic for when the hectic timer times out.
func _on_hectic_timer_timeout() -> void:
	if not _hecticCountdownActive:
		return

	_stopHecticMode()
	_closeAllOptionWindows()

	if hecticFailureDialogueID == "":
		DebugHud.addToLog("DialogueConsole:  nextOnHecticFailureID not set for [" + currentDialogueID + "]", DebugHud.LogType.ERROR)

	option_chosen.emit(hecticFailureDialogueID)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Editor-use Only.[/b]
## Returns editor warnings depending on this thing's state.
func _get_configuration_warnings() -> PackedStringArray:
	return super()

## [b]Editor-use Only.[/b]
## Hides certain export fields depending on this thing's state.
func _validate_property(property:Dictionary) -> void:
	super(property)
