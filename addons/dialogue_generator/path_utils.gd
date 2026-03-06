extends RefCounted
class_name DialoguePathUtils

# Base root where everything goes (writeable)
const BASE_DIR := Globals.STORAGE_PATH.DIALOGUE

# Make a folder-safe name (avoids weird characters)
static func sanitize_name(s: String) -> String:
	var t := s.strip_edges()
	t = t.replace(" ", "_")
	return t

# Ensure NPC folder exists, return its path
static func ensure_npc_dir(npc_name: String) -> String:
	var npc_dir := get_npc_dir(npc_name)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(npc_dir))
	return npc_dir


# Return the json file path for an NPC (ensures folder exists)
static func get_npc_dir(npc_name: String) -> String:
	var safe := sanitize_name(npc_name).to_upper()
	return BASE_DIR.path_join(safe)

static func get_dialogue_path(npc_name: String, dialogue_id: String) -> String:
	var npc_dir := get_npc_dir(npc_name)
	return npc_dir.path_join("%s.json" % dialogue_id)

# List all NPC folders under BASE_DIR
static func list_npcs() -> Array[String]:
	DirAccess.make_dir_recursive_absolute(BASE_DIR)
	var dir := DirAccess.open(BASE_DIR)
	if dir == null:
		return []

	var out: Array[String] = []
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name == "":
			break
		if dir.current_is_dir() and not name.begins_with("."):
			out.append(name)
	dir.list_dir_end()
	out.sort()
	return out

# List json files for a given NPC folder
static func list_npc_json_files(npc_name: String) -> Array[String]:
	var npc_dir := ensure_npc_dir(npc_name)
	var dir := DirAccess.open(npc_dir)
	if dir == null:
		return []

	var out: Array[String] = []
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name == "":
			break
		if dir.current_is_dir():
			continue
		if name.to_lower().ends_with(".json"):
			out.append(name)
	dir.list_dir_end()
	out.sort()
	return out
