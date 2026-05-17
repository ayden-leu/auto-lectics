extends AudioStreamPlayer
class_name VocalDialoguePlayer

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------



# ------------------------------------------------
# export variables
# ------------------------------------------------
@export var VOCAL_DIALOGUE_PATH: String = "res://dialogue_trees/vocal/"
@export var AUDIO_FILE_EXTENSION: String = ".mp3"
@export var vocal_dialogue_enabled: bool = true
@export var initial_vocal_dialogue_id: String = "intro_001"
@export var _delay_before_allow_continue: float = 0.0
# ------------------------------------------------
# onready variables
# ------------------------------------------------

@onready var subtitles_label: Label = $Subtitles
@onready var continue_icon: TextureRect = $ContinueIcon

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

var current_vocal_dialogue_id: String = ""

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------


var _next_vocal_dialogue_id: String = ""
var _can_continue: bool = true

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

func _ready() -> void:
	current_vocal_dialogue_id = initial_vocal_dialogue_id

	subtitles_label.visible = false
	continue_icon.visible = false

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

func begin_buildup() -> void:
	if not vocal_dialogue_enabled:
		return

	if not _can_continue:
		return

	_can_continue = false

	var file_path: String = VOCAL_DIALOGUE_PATH + current_vocal_dialogue_id + ".json"
	var dialogue_data: Dictionary = DialogueLoader.loadDialogueNodeFile(file_path)

	if dialogue_data.is_empty():
		push_error("Loaded vocal dialogue file is empty or invalid: " + file_path)
		_can_continue = true
		return

	if not _verify_vocal_dialogue_file(dialogue_data):
		_can_continue = true
		return

	_prepare_vocal_dialogue(dialogue_data)
	await _start_vocal_dialogue()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

func _verify_vocal_dialogue_file(dialogue_data: Dictionary) -> bool:
	var required_fields: Array[String] = [
		"file",
		"subtitles",
		"delayBeforeAllowContinue",
		"nextID"
	]

	for field in required_fields:
		if not dialogue_data.has(field):
			push_error("Vocal dialogue file is missing field: " + field)
			return false

	return true


func _prepare_vocal_dialogue(dialogue_data: Dictionary) -> void:
	_can_continue = false
	continue_icon.visible = false

	var audio_file_name: String = dialogue_data["file"]
	var audio_path: String = VOCAL_DIALOGUE_PATH + audio_file_name + AUDIO_FILE_EXTENSION

	var loaded_audio: AudioStream = load(audio_path)

	if loaded_audio == null:
		push_error("Could not load vocal dialogue audio file: " + audio_path)
		_can_continue = true
		return

	stream = loaded_audio
	subtitles_label.text = dialogue_data["subtitles"]
	_delay_before_allow_continue = float(dialogue_data["delayBeforeAllowContinue"])
	_next_vocal_dialogue_id = dialogue_data["nextID"]


func _start_vocal_dialogue() -> void:
	subtitles_label.visible = true
	subtitles_label.modulate.a = 1.0
	play()

	await finished

	if _delay_before_allow_continue > 0.0:
		#await get_tree().create_timer(_delay_before_allow_continue).finished
		var timer: SceneTreeTimer = get_tree().create_timer(_delay_before_allow_continue)
		if timer != null:
			await timer.timeout

	await _fade_out_subtitles()
	
	continue_icon.visible = true
	_can_continue = true

	if _next_vocal_dialogue_id != "":
		current_vocal_dialogue_id = _next_vocal_dialogue_id
		
		
# additional for subtatil
func _fade_out_subtitles() -> void:
	var tween: Tween = create_tween()

	tween.tween_property(
		subtitles_label,
		"modulate:a",
		0.0,
		1.0
	)

	await tween.finished

	subtitles_label.visible = false

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

func _on_input_handler_interact_button_pressed() -> void:
	print("signal received")
	
	if _can_continue and vocal_dialogue_enabled:
		begin_buildup()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
