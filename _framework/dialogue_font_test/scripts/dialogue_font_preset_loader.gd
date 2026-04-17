extends RefCounted
class_name DialogueFontPresetLoader

static func get_preset_path(preset_name: String) -> String:
	return "res://addons/dialogue_font_test/presets/%s.tres" % preset_name

static func load_preset(preset_name: String) -> LabelSettings:
	if preset_name.strip_edges().is_empty():
		return null

	var path := get_preset_path(preset_name)

	if not ResourceLoader.exists(path):
		push_warning("Dialogue font preset not found: %s" % path)
		return null

	var resource := load(path)
	if resource is LabelSettings:
		return resource

	push_warning("Resource exists but is not a LabelSettings: %s" % path)
	return null
