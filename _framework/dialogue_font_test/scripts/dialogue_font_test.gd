extends Control

const DIALOGUE_FILE_PATH := "res://addons/dialogue_font_test/data/test_dialogue.json"

@onready var dialogue_label: Label = $DialogueLabel

func _ready() -> void:
	load_dialogue_file(DIALOGUE_FILE_PATH)

func load_dialogue_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("Dialogue file not found: %s" % path)
		dialogue_label.text = "Dialogue file not found."
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue file: %s" % path)
		dialogue_label.text = "Failed to open dialogue file."
		return

	var raw_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(raw_text)

	if parse_result != OK:
		push_error("Failed to parse JSON in %s" % path)
		dialogue_label.text = "Invalid dialogue JSON."
		return

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Dialogue JSON root must be a dictionary.")
		dialogue_label.text = "Dialogue data format error."
		return

	apply_dialogue_data(data)

func apply_dialogue_data(data: Dictionary) -> void:
	var dialogue_text := str(data.get("text", ""))
	var font_preset := str(data.get("font", ""))

	dialogue_label.text = dialogue_text

	# Clear existing preset first
	dialogue_label.label_settings = null

	if not font_preset.strip_edges().is_empty():
		var preset := DialogueFontPresetLoader.load_preset(font_preset)
		if preset != null:
			dialogue_label.label_settings = preset
		else:
			push_warning("No matching font preset found for '%s'" % font_preset)
