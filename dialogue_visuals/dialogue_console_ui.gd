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

var realOwner: Node = null
var ownerName: String = ""
var currentDialogueID: String = ""
var mode: String = "normal"
var hecticFailureDialogueID: String = ""
var delayBtwnWriteDialogueAndOptions: float = 0.25
var textWriteSpeed: float = 20.0
var sfxEventsToLoad: Dictionary = {}

var _dialogue_data: Dictionary = {}
var _visible_options: Array = []
var _spawned_option_windows: Array = []
var _is_typing: bool = false

func _ready() -> void:
	_center_main_window()
	input_line.text_submitted.connect(_on_input_submitted)
	input_line.grab_focus()

func set_npc_id(id: String) -> void:
	ownerName = id
	print (ownerName)
	$Window/Header/NPCName.text = ownerName

func prepare() -> void:
	_clear_option_windows()
	input_line.text = ""


func start() -> void:
	await _type_dialogue_text(str(_dialogue_data.get("text", "")))
	all_dialogue_text_visible.emit()
	
	await get_tree().create_timer(delayBtwnWriteDialogueAndOptions).timeout
	_spawn_option_windows()
	all_options_available.emit()


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

	dialogue_log.append_text("[indent][indent][indent][indent][indent][indent][indent][indent][color=#f2a11a]")

	for i in range(full_text.length()):
		dialogue_log.append_text(full_text[i])
		_scroll_to_bottom()
		await get_tree().create_timer(delay).timeout

	dialogue_log.append_text("[/color][/indent][/indent][/indent][/indent][/indent][/indent][/indent][/indent]\n\n")
	_scroll_to_bottom()

	_is_typing = false

## prints the player text if they picked an option with text associated
func add_player_text(full_text: String) -> void:
	dialogue_log.append_text("[color=#ffffff]%s[/color]\n\n" % full_text)
	_scroll_to_bottom()
	

## scrolls the dialogue log down
func _scroll_to_bottom() -> void:
	#await get_tree().process_frame
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
		
		#if mode == "hectic":
			#win.position = _random_popup_position(win.size)
		#else:
			
		win.position = Vector2(40, 120 + i * 90)
		
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
	
	if text.to_lower() == "back":
		request_back.emit()
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
	await get_tree().process_frame
	input_line.grab_focus()


func _choose_option(option_data: Dictionary) -> void:
	var option_text: String = str(option_data.get("text", "")).strip_edges()
	if option_text != "->":
		add_player_text(option_text)
		
	var set_flags_dict := _convert_flag_array_to_dict(option_data.get("setFlag", []))
	if not set_flags_dict.is_empty():
		StoryFlags.apply_set_flags(set_flags_dict)
	
	_clear_option_windows()
	option_chosen.emit(str(option_data.get("nextID", "")))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventKey and event.pressed and event.ctrl_pressed and event.keycode == KEY_Z:
		request_back.emit()
		get_viewport().set_input_as_handled()


func kill() -> void:
	queue_free()



func _clear_option_windows() -> void:
	for w in _spawned_option_windows:
		if is_instance_valid(w):
			w.queue_free()
	_spawned_option_windows.clear()


func _center_main_window() -> void:
	await get_tree().process_frame
	main_window.position = (get_viewport_rect().size - main_window.size) * 0.5


func _random_popup_position(window_size: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(
		randf_range(0.0, max(0.0, viewport_size.x - window_size.x)),
		randf_range(0.0, max(0.0, viewport_size.y - window_size.y))
	)
