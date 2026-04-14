extends Control
class_name DialogueConsoleUI

signal option_chosen(next_id: String)
signal request_back
signal all_dialogue_text_visible
signal new_option_available
signal all_options_available

@export var option_window_scene: PackedScene

@onready var main_window: Panel = $Window
@onready var input_line: LineEdit = $Window/InputLine
@onready var option_layer: Control = $Options
@onready var scroll_container: ScrollContainer = $Window/ScrollContainer
@onready var dialogue_log: RichTextLabel = $Window/ScrollContainer/DialogueLog
@onready var npc_name: Label = $Window/Header/NPCName
@onready var hectic_bar: ProgressBar = $Window/HecticBar
@onready var hectic_timer: Timer = $HecticTimer

var realOwner: Node = null
var ownerName: String = ""
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

## Show this message when "help" is inputted
var help_text: String = "Here are the commands:\n" + \
		"0, 1, 2...  = choose an option by ID\n" + \
		"back        = go back one dialogue\n" + \
		"exit         = close the console"


func _ready() -> void:
	_center_main_window()
	input_line.text_submitted.connect(_on_input_submitted)
	input_line.grab_focus()
	
	hectic_timer.one_shot = true

	hectic_bar.visible = false
	hectic_bar.min_value = 0.0
	hectic_bar.max_value = 100.0
	hectic_bar.value = 100.0

func set_npc_id(id: String) -> void:
	ownerName = id
	print (ownerName)
	$Window/Header/NPCName.text = ownerName

func prepare() -> void:
	_clear_option_windows()
	input_line.text = ""
	_stop_hectic_mode()


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
	if ownerName == "dropPod":
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
		if StoryFlags.passes_check_flags(check_flags_dict):
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
	
	if option_window_scene == null:
		push_error("DialogueConsoleUI: option_window_scene is not assigned.")
		return
	
	for i in range(_visible_options.size()):
		var opt: Dictionary = _visible_options[i]
		var win = option_window_scene.instantiate()
		option_layer.add_child(win)
		
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
	input_line.text = ""
	
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
		
	if text == "":
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
	$Window/InputLine.edit()


func _choose_option(option_data: Dictionary) -> void:
	var option_text: String = str(option_data.get("text", "")).strip_edges()
	if option_text != "->":
		add_player_text(option_text)
	_stop_hectic_mode()
	
	var set_flags_dict := _convert_flag_array_to_dict(option_data.get("setFlag", []))
	if not set_flags_dict.is_empty():
		StoryFlags.apply_set_flags(set_flags_dict)
	
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
	main_window.position = (get_viewport_rect().size - main_window.size) * 0.5


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
		AudioLoader.clearAudioFiles(sfxPlayer[eventID].stream)
		AudioLoader.loadAudioFiles(sfxEventsToLoad[eventID], sfxPlayer[eventID].stream)
