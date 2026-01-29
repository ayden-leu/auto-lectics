extends Node
class_name DialogueDB

var language := "en"
var _cache: Dictionary = {} # key: path, value: parsed dict

func set_language(lang: String) -> void:
	language = lang

func load_conversation(file_name: String) -> Dictionary:
	# file_name example: "npc_guide_intro.json"
	var path := "res://dialogue/%s/%s" % [language, file_name]

	if _cache.has(path):
		return _cache[path]

	if not FileAccess.file_exists(path):
		push_error("Dialogue file not found: " + path)
		return {}

	var json_text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(json_text)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("Dialogue JSON parse failed: " + path)
		return {}

	_cache[path] = parsed
	return parsed
