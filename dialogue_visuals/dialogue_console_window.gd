extends Panel
class_name DialogueConsole
## [b]Internal-use only.[/b]  The main console-like window for interacting with
## a dialogue event.


# TODO
# 	make options just spawn in the scene and not as children as its not needed
#		(had to do it for DialogueBox due to it existing in 3D space)
#		nevermind I forgot that positioning is dependant on console position
#	combine this script with dialgoue_console_main_window.gd
#	make a window manager?

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

## Emitted when the back command is entered.
signal request_back
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
const _OPTION_WINDOW_SCENE:Resource = preload(Globals.SCENES.DialogueConsoleOptionWindow)

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
@onready var _textInput: LineEdit = $InputLine
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var dialogue_log: RichTextLabel = $ScrollContainer/DialogueLog
@onready var npc_name: Label = $Header/NPCName
@onready var hectic_bar: ProgressBar = $HecticBar
@onready var hectic_timer: Timer = $HecticTimer

## [b]Internal-use only.[/b]  Holds the root positions for spawning option windows
## in normal mode.
@onready var _optionSpawnPositions = [
	%OptionAnchors/TopLeft, %OptionAnchors/TopRight,
	%OptionAnchors/BottomLeft, %OptionAnchors/BottomRight
]
# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
var ownerName:String = ""

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------










var realOwner: Node = null

var currentDialogueID: String = ""
var mode: String = "normal"
var hecticFailureDialogueID: String = ""
var delayBtwnWriteDialogueAndOptions: float = 0.25
var textWriteSpeed: float = 20.0
var sfxEventsToLoad: Dictionary = {}:
	set(value):
		sfxEventsToLoad = value
		loadSfx()

var _dialogue_data: Dictionary = {}
var _visible_options: Array = []
var _spawned_option_windows: Array = []
var _is_typing: bool = false

var hectic_duration: float = 5.0
var _hectic_time_left: float = 0.0
var _hectic_active: bool = false

var _npcsThatPreventClosing:Array[String] = [
	"dropPod", "The Office"
]

## Show this message when "help" is inputted
var help_text: String = "Here are the commands:\n\n" + \
		"0, 1, 2...  =  choose an option by ID \n\n(you can also type out the text but that would take forever)\n\n" + \
		"back        =  reverse one dialog\n\n (feel free to use this if the AI's are getting argumentative, they're coded to respect the command) \n\n" + \
		"exit         =  close the console"


func _ready() -> void:
	_center_main_window()
	_textInput.text_submitted.connect(_on_input_submitted)
	_textInput.grab_focus()
	
	hectic_timer.one_shot = true

	hectic_bar.visible = false
	hectic_bar.min_value = 0.0
	hectic_bar.max_value = 100.0
	hectic_bar.value = 100.0

func set_npc_id(id: String) -> void:
	ownerName = id
	print (ownerName)
	npc_name.text = ownerName

func prepare() -> void:
	_clear_option_windows()
	_textInput.text = ""
	_stop_hectic_mode()
	
	npc_name.text = ownerName


func start() -> void:
	sfxPlayer.spawn.play()
	
	await _type_dialogue_text(str(_dialogue_data.get("text", "")))
	all_dialogue_text_visible.emit()
	
	await get_tree().create_timer(delayBtwnWriteDialogueAndOptions).timeout
	_spawn_option_windows()
	all_options_available.emit()
	_refocus_input()
	
	if mode == "hectic":
		_start_hectic_mode()


## exit window on "exit" or pressing X button
func exit_window() -> void:
	## If you don't want player to exit from certain NPCs, put exceptions here
	if ownerName in _npcsThatPreventClosing:
		add_player_text("exit")
		_type_dialogue_text("Wait, you must listen first.")
		return
	option_chosen.emit("")


func _process(delta: float) -> void:
	if _hectic_active:
		_hectic_time_left = max(_hectic_time_left - delta, 0.0)
		if hectic_duration > 0.0:
			hectic_bar.value = (_hectic_time_left / hectic_duration) * 100.0
		else:
			hectic_bar.value = 0.0

## helper function to convert a flag array to the intended dictionary input
func _convert_flag_array_to_dict(flag_array: Variant) -> Dictionary:
	var out: Dictionary = {}
	
	if typeof(flag_array) == TYPE_DICTIONARY:
		return flag_array
	
	if typeof(flag_array) != TYPE_ARRAY:
		return out
	
	for entry in flag_array:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		
		var flag_name: String = str(entry.get("flagName", ""))
		if flag_name == "":
			continue
		
		out[flag_name] = entry.get("value")
	
	return out


## Loads the data of all posible options for this dialogue object. Also sorts the options from shortest to longest spawn delay.
func loadOptionData(options: Array) -> void:
	_visible_options.clear()
	
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			continue
	
		var check_flags_dict := _convert_flag_array_to_dict(option.get("checkFlag", []))
		if StoryFlags.flagsMatch(check_flags_dict):
			_visible_options.push_back(option)

	_visible_options.sort_custom(func(a, b): return a.get("spawnDelay", 0.0) < b.get("spawnDelay", 0.0))


func show_dialogue_data(dialogue_data: Dictionary) -> void:
	_dialogue_data = dialogue_data


func _type_dialogue_text(full_text: String) -> void:
	_is_typing = true
	
	var cps: float = max(textWriteSpeed, 1.0)
	var delay: float = 1.0 / cps
	
	dialogue_log.append_text("[indent][indent][indent][indent][indent][indent][color=#f2a11a]")
	
	for i in range(full_text.length()):
		dialogue_log.append_text(full_text[i])
		_scroll_to_bottom()
		sfxPlayer.text.play()
		await get_tree().create_timer(delay).timeout
	
	dialogue_log.append_text("[/color][/indent][/indent][/indent][/indent][/indent][/indent]\n\n")
	_scroll_to_bottom()
	
	_is_typing = false

## prints the player text if they picked an option with text associated
func add_player_text(full_text: String) -> void:
	dialogue_log.append_text("[color=#ffffff]%s[/color]\n\n" % full_text)
	_scroll_to_bottom()
	

## scrolls the dialogue log down
func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)


func _spawn_option_windows() -> void:
	_refocus_input()
	if _visible_options.is_empty():
		all_options_available.emit()
		return
	
	for i in range(_visible_options.size()):
		var opt: Dictionary = _visible_options[i]
		var win = _OPTION_WINDOW_SCENE.instantiate()
		get_parent().add_child(win)
		
		win.set_option_data(i, str(opt.get("text", "")))
		win.option_selected.connect(_on_option_window_selected.bind(opt))
		win.position = Vector2(40, 120 + i * 120)
		
		_spawned_option_windows.push_back(win)
		new_option_available.emit()
	
	all_options_available.emit()


func _on_option_window_selected(option_data: Dictionary) -> void:
	_choose_option(option_data)


func _on_input_submitted(raw_text: String) -> void:
	if _is_typing:
		return
	var text := raw_text.strip_edges()
	_textInput.text = ""
	
	if text.to_lower() == "help":
		add_player_text("help")
		await _type_dialogue_text(help_text)
		return
	
	if text.to_lower() == "back":
		request_back.emit()
		return
	
	if text.to_lower() == "exit":
		exit_window()
		return
	
	if text.to_lower() == "open_gate" && ownerName == "mini-BOSS":
		add_player_text("open_gate")
		open_gate.emit()
		return
	
	if text.is_valid_int():
		var idx := int(text)
		if idx >= 0 and idx < _visible_options.size():
			_choose_option(_visible_options[idx])
			return
	
	for opt in _visible_options:
		if text.to_lower() == str(opt.get("text", "")).to_lower():
			_choose_option(opt)
			return

## This is supposed to make the input line selected again when a option is selected; it doesn't work for me
func _refocus_input() -> void:
	_textInput.edit()


func _choose_option(option_data: Dictionary) -> void:
	var option_text: String = str(option_data.get("text", "")).strip_edges()
	if option_text != "->":
		add_player_text(option_text)
	_stop_hectic_mode()
	
	var set_flags_dict := _convert_flag_array_to_dict(option_data.get("setFlag", []))
	if not set_flags_dict.is_empty():
		StoryFlags.updateFlags(set_flags_dict)
	
	_clear_option_windows()
	option_chosen.emit(str(option_data.get("nextID", "")))


func kill() -> void:
	_stop_hectic_mode()
	queue_free()


func _clear_option_windows() -> void:
	for w in _spawned_option_windows:
		if is_instance_valid(w):
			w.queue_free()
	_spawned_option_windows.clear()


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
	_hectic_active = true
	_hectic_time_left = hectic_duration
	hectic_bar.visible = true
	hectic_bar.value = 100.0
	hectic_timer.start(hectic_duration)

func _stop_hectic_mode() -> void:
	_hectic_active = false
	_hectic_time_left = 0.0
	if hectic_timer:
		hectic_timer.stop()
	if hectic_bar:
		hectic_bar.visible = false
		hectic_bar.value = 100.0

func _on_hectic_timeout() -> void:
	if not _hectic_active:
		return

	_stop_hectic_mode()
	_clear_option_windows()

	option_chosen.emit(hecticFailureDialogueID)

# =======================================

func _on_close_button_pressed() -> void:
	exit_window()

## Holds the AudioStreamPlayer3Ds for each event.
@onready var sfxPlayer:Dictionary[String, AudioStreamPlayer] = {
	"spawn": %SFX/spawn,
	"text": %SFX/text
}

func loadSfx() -> void:
	for eventID in sfxPlayer.keys():
		AudioLoader.clearAudioRandomizer(sfxPlayer[eventID].stream)
		AudioLoader.loadSfxFromId(sfxEventsToLoad[eventID], sfxPlayer[eventID].stream)

var _dragging := false
var _drag_offset := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if _dragging:
			_drag_offset = get_global_mouse_position() - global_position
	
	if event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
