@tool
extends DialogueWindow
class_name DialogueConsole
## [b]Internal-use only.[/b]  The main console-like window for interacting with
## a dialogue event.

# TODO
# 	make options just spawn in the scene and not as children as its not needed
#		(had to do it for DialogueBox due to it existing in 3D space)
#		nevermind I forgot that positioning is dependant on console position
#		nevermind nevermind???  i dont know anymore
#	make a window manager?
#	make each entry of dialogue a separate RichTextLabel
#		solves hardcoded text aligning

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when an option is chosen.
signal option_chosen(next_id: String)
## Emitted when all dialogue for a dialogue tree node is visible.
signal all_dialogue_text_visible
## Emitted when a new dialogue option is visible.
signal new_option_available
## Emitted when all dialogue options is visible.
signal all_options_available

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
## [b]Internal-use only.[/b]  A reference to the [DialogueConsoleOptionWindow] scene.
const _OPTION_WINDOW_SCENE:Resource = preload(FR_Globals.SCENES.DialogueConsoleOptionWindow)

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
## [b]Internal-use only.[/b]  The contents of the console.
@onready var _contents: RichTextLabel = %DialogueLog
## [b]Internal-use only.[/b]  The progress bar that displays how much time is left
## until a hectic dialogue event ends.
@onready var _hecticBar: ProgressBar = $HecticBar
## [b]Internal-use only.[/b]  The hectic dialogue event timer.
@onready var _hecticTimer: Timer = $HecticTimer
## [b]Internal-use only.[/b]  Holds the root positions for spawning option windows
## in normal mode.
@onready var _optionSpawnPositions = [
	%OptionAnchors/TopLeft, %OptionAnchors/TopRight,
	%OptionAnchors/BottomLeft, %OptionAnchors/BottomRight
]
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
var hecticDuration:float = 5.0  # TODO  make this customizable

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
## @deprecated
## [b]Internal-use only.[/b]  A list of [InteractableNPC]s that make it so
## you cannot close this window.
var _npcsThatPreventClosing:Array[String] = [  # TODO:  make this a boolean varaible that is set by InteractableNPC
	"dropPod", "The Office"
]
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
	
	_center_main_window()
	
	
	_hecticTimer.one_shot = true

	_hecticBar.visible = false
	_hecticBar.min_value = 0.0
	_hecticBar.max_value = 100.0
	_hecticBar.value = 100.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if _hecticCountdownActive:
		_hecticBar.value = (_hecticTimer.time_left / hecticDuration) * 100.0
	
	if Input.is_action_just_pressed("debug_2"):
		print(_dialogueHistory)

func _gui_input(event: InputEvent) -> void:
	super(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

func prepare() -> void:
	_clear_option_windows()
	_textInput.text = ""
	_stop_hectic_mode()
	
	if _recordHistory:
		_dialogueHistory.push_back(currentDialogueID)
	_recordHistory = true
	
	headerText = nameOfNpcTalkingTo
	_textInput.grab_focus()

func start() -> void:
	_sfxPlayer.spawn.play()
	
	await _type_dialogue_text(textToAdd)
	all_dialogue_text_visible.emit()
	
	await get_tree().create_timer(delayBtwnWriteDialogueAndOptions).timeout
	_spawn_option_windows()
	all_options_available.emit()
	_refocus_input()
	
	if mode == "hectic":
		_start_hectic_mode()

## Loads the data of all posible options for this dialogue object. Also sorts the options from shortest to longest spawn delay.
func loadOptionData(options: Array) -> void:
	_optionData.clear()
	
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			continue
		
		if StoryFlags.flagsMatch(option.checkFlags):
			_optionData.push_back(option)

	_optionData.sort_custom(func(a, b): return a.spawnDelay < b.spawnDelay)

func loadSfx(sfxEventsToLoad:Dictionary) -> void:
	for eventID in _sfxPlayer.keys():
		_sfxPlayer[eventID].stop()
		AudioLoader.clearAudioRandomizer(_sfxPlayer[eventID].stream)
		AudioLoader.loadSfxFromId(sfxEventsToLoad[eventID], _sfxPlayer[eventID].stream)

## prints the player text if they picked an option with text associated
func add_player_text(full_text: String) -> void:
	_contents.append_text("[color=#ffffff]%s[/color]\n\n" % full_text)
	_scroll_to_bottom()

func kill() -> void:
	_stop_hectic_mode()
	_clear_option_windows()
	_dialogueHistory.clear()
	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## exit window on "exit" or pressing X button
func close() -> void:
	if nameOfNpcTalkingTo in _npcsThatPreventClosing:
		add_player_text("exit")
		_type_dialogue_text("Wait, you must listen first.")
		return
	option_chosen.emit("")  # TODO:  use the close signal instead to close this.
	
	super()

func _type_dialogue_text(full_text: String) -> void:
	_isWritingText = true
	
	var cps: float = max(textWriteSpeed, 1.0)
	var delay: float = 1.0 / cps
	
	_contents.append_text("[indent][indent][indent][indent][indent][indent][color=#f2a11a]")
	
	for i in range(full_text.length()):
		_contents.append_text(full_text[i])
		_scroll_to_bottom()
		if not _sfxPlayer.text.playing:
			_sfxPlayer.text.play()
		await get_tree().create_timer(delay).timeout
	
	_contents.append_text("[/color][/indent][/indent][/indent][/indent][/indent][/indent]\n\n")
	_scroll_to_bottom()
	
	_isWritingText = false

## scrolls the dialogue log down
func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	_contentsScroller.scroll_vertical = _contentsScroller.get_v_scroll_bar().max_value

## Forces current selection to be on the input area.
func _refocus_input() -> void:
	_textInput.edit()

func _spawn_option_windows() -> void:
	_refocus_input()
	
	for i in range(_optionData.size()):
		var opt: Dictionary = _optionData[i]
		var win = _OPTION_WINDOW_SCENE.instantiate()
		get_parent().add_child(win)
		
		win.id = i
		win.text = opt.get("text", "")
		win.option_selected.connect(_on_option_window_selected.bind(opt))
		win.position = Vector2(40, 120 + i * 120)
		
		_optionWindows.push_back(win)
		new_option_available.emit()
	
	all_options_available.emit()

func _choose_option(option_data: Dictionary) -> void:
	var option_text: String = str(option_data.get("text", "")).strip_edges()
	if option_text != "->":
		add_player_text(option_text)
	_stop_hectic_mode()
	
	if option_data:
		StoryFlags.updateFlags(option_data.setFlags)
	else:
		printerr("No option data?  Might be intentional.")
	
	_clear_option_windows()
	option_chosen.emit(str(option_data.get("nextID", "")))

func _clear_option_windows() -> void:
	for w in _optionWindows:
		if is_instance_valid(w):
			w.queue_free()
	_optionWindows.clear()

func _center_main_window() -> void:
	await get_tree().process_frame
	#position = (get_viewport_rect().size - size) * 0.5
	position = (get_viewport_rect().size - size) / 2

## Currently unused, since it leads to overlap between options and main window
func _random_popup_position(window_size: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(
		randf_range(0.0, max(0.0, viewport_size.x - window_size.x)),
		randf_range(0.0, max(0.0, viewport_size.y - window_size.y))
	)

func _start_hectic_mode() -> void:
	_hecticCountdownActive = true
	_hecticBar.visible = true
	_hecticBar.value = 100.0
	_hecticTimer.start(hecticDuration)

func _stop_hectic_mode() -> void:
	_hecticCountdownActive = false
	if _hecticTimer:
		_hecticTimer.stop()
	if _hecticBar:
		_hecticBar.visible = false
		_hecticBar.value = 100.0

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

func _on_option_window_selected(option_data: Dictionary) -> void:
	_choose_option(option_data)


func _on_input_submitted(raw_text: String) -> void:
	if _isWritingText:
		return
	var text := raw_text.strip_edges()
	_textInput.text = ""
	
	if text.to_lower() == "help":
		add_player_text("help")
		await _type_dialogue_text(_helpText)
		return
	
	if text.to_lower() == "back":
		_on_console_request_back()
		return
	
	if text.to_lower() == "exit":
		close()
		return
	
	if text.to_lower() == "open_gate" && nameOfNpcTalkingTo == "mini-BOSS":
		add_player_text("open_gate")
		open_gate.emit()
		return
	
	if text.is_valid_int():
		var idx := int(text)
		if idx >= 0 and idx < _optionData.size():
			_choose_option(_optionData[idx])
			return
	
	for opt in _optionData:
		if text.to_lower() == str(opt.get("text", "")).to_lower():
			_choose_option(opt)
			return

func _on_console_request_back() -> void:
	print("back: ", _dialogueHistory)
	if _dialogueHistory.size() <= 1:
		add_player_text("[no recorded history in log]")
		return
	
	_dialogueHistory.pop_back()
	add_player_text("back")
	_recordHistory = false
	var previous_id: String = _dialogueHistory.back()
	option_chosen.emit(previous_id)
	return

func _on_hectic_timeout() -> void:
	if not _hecticCountdownActive:
		return

	_stop_hectic_mode()
	_clear_option_windows()
	
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
