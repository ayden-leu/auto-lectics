extends Control

const DIALOGUE_FILE_PATH := "res://addons/dialogue_font_test/data/test_dialogue.json"
const PRESET_LOADER = preload("res://addons/dialogue_font_test/scripts/dialogue_font_preset_loader.gd")

@onready var dialogue_label: Label = $DialogueLabel

func _ready() -> void:
	print("DialogueFontTest _ready called")

	if dialogue_label == null:
		print("DialogueLabel not found")
		return

	dialogue_label.visible = true
	dialogue_label.text = "Scene loaded. Trying to load dialogue..."

	load_dialogue_file(DIALOGUE_FILE_PATH)

func load_dialogue_file(path: String) -> void:
	print("Loading file: ", path)

	if not FileAccess.file_exists(path):
		print("Dialogue file not found: ", path)
		dialogue_label.text = "Dialogue file not found."
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Failed to open dialogue file")
		dialogue_label.text = "Failed to open dialogue file."
		return

	var raw_text := file.get_as_text()
	file.close()

	print("Raw JSON: ", raw_text)

	var json := JSON.new()
	var err := json.parse(raw_text)

	if err != OK:
		print("JSON parse failed: ", err)
		dialogue_label.text = "Invalid JSON."
		return

	if typeof(json.data) != TYPE_DICTIONARY:
		print("JSON root is not a dictionary")
		dialogue_label.text = "JSON root must be an object."
		return

	var data: Dictionary = json.data
	apply_dialogue_data(data)

func apply_dialogue_data(data: Dictionary) -> void:
	var dialogue_text := str(data.get("text", "NO TEXT FOUND"))
	var font_preset := str(data.get("font", ""))

	print("Dialogue text: ", dialogue_text)
	print("Font preset: ", font_preset)

	dialogue_label.text = dialogue_text
	dialogue_label.label_settings = null

	if not font_preset.strip_edges().is_empty():
		var preset := PRESET_LOADER.load_preset(font_preset)
		if preset != null:
			print("Preset loaded successfully")
			dialogue_label.label_settings = preset
		else:
			print("Preset not found: ", font_preset)
