extends Node
class_name DialogueLoader

# Loads a single dialogue node file (like Dialogue1a.json)
# Returns a normalised Dictionary (with defaults + resolved inheritance)
func load_dialogue_node_file(path: String) -> Dictionary:
	var json_text := _read_text_file(path)
	if json_text == "":
		push_error("DialogueLoader: Missing/empty file: %s" % path)
		return {}

	var raw = JSON.parse_string(json_text)
	if typeof(raw) != TYPE_DICTIONARY:
		push_error("DialogueLoader: Expected a JSON object at root: %s" % path)
		return {}

	return _normalise_dialogue(raw)


# -------------------------
# Normalisation
# -------------------------
func _normalise_dialogue(raw: Dictionary) -> Dictionary:
	var dlg := DialogueDefaults.default_dialogue()

	# Basic fields
	dlg["text"] = str(raw.get("text", dlg["text"]))
	dlg["font"] = str(raw.get("font", dlg["font"]))
	dlg["type"] = _safe_enum(str(raw.get("type", dlg["type"])).to_lower(), DialogueDefaults.DIALOGUE_TYPES, dlg["type"])
	dlg["mode"] = str(raw.get("mode", dlg["mode"])).to_lower()

	# Typewriter
	dlg["writeSpeed"] = str(raw.get("writeSpeed", dlg["writeSpeed"])).to_lower()
	dlg["writeSpeedCustom"] = float(raw.get("writeSpeedCustom", dlg["writeSpeedCustom"]))

	# SFX
	if raw.has("sfx"):
		dlg["sfx"] = _merge_sfx(dlg["sfx"], raw["sfx"])

	# Background theme
	dlg["backgroundTheme"] = str(raw.get("backgroundTheme", dlg["backgroundTheme"]))

	# Particles
	if raw.has("particles"):
		dlg["particles"] = _merge_particles(dlg["particles"], raw["particles"])

	# Options
	dlg["options"] = []
	var raw_options = raw.get("options", [])
	if typeof(raw_options) == TYPE_ARRAY:
		for opt_raw in raw_options:
			if typeof(opt_raw) != TYPE_DICTIONARY:
				continue
			var opt := _normalise_option(opt_raw, dlg)
			dlg["options"].append(opt)

	return dlg


func _normalise_option(raw: Dictionary, dlg: Dictionary) -> Dictionary:
	var opt := DialogueDefaults.default_option()

	# Required-ish
	opt["text"] = str(raw.get("text", opt["text"]))
	opt["font"] = str(raw.get("font", opt["font"]))
	opt["type"] = _safe_enum(str(raw.get("type", opt["type"])).to_lower(), DialogueDefaults.OPTION_TYPES, opt["type"])

	# Typewriter
	opt["writeSpeed"] = str(raw.get("writeSpeed", opt["writeSpeed"])).to_lower()
	opt["writeSpeedCustom"] = float(raw.get("writeSpeedCustom", opt["writeSpeedCustom"]))

	# SFX
	if raw.has("sfx"):
		# If sfx is {}, inherit spawn/text from dialogue (your NOTE)
		opt["sfx"] = _merge_sfx(opt["sfx"], raw["sfx"])

	# Background theme
	opt["backgroundTheme"] = str(raw.get("backgroundTheme", opt["backgroundTheme"]))

	# Particles
	if raw.has("particles"):
		# If particles is {}, inherit spawn/text/ambient from dialogue (your NOTE)
		opt["particles"] = _merge_particles(opt["particles"], raw["particles"])

	# Timing / linking
	opt["spawnDelay"] = float(raw.get("spawnDelay", opt["spawnDelay"]))
	opt["lifetime"] = float(raw.get("lifetime", opt["lifetime"]))
	opt["nextID"] = str(raw.get("nextID", opt["nextID"]))

	# Resolve inheritance against dialogue
	_resolve_option_inheritance(opt, dlg)

	return opt


# -------------------------
# Inheritance rules
# -------------------------
func _resolve_option_inheritance(opt: Dictionary, dlg: Dictionary) -> void:
	# Font
	if opt["font"] == "inherit":
		opt["font"] = dlg["font"]

	# Write speed preset
	if opt["writeSpeed"] == "inherit":
		opt["writeSpeed"] = dlg["writeSpeed"]

	# Write speed custom:
	# if option custom is -1, inherit dialogue custom (or keep -1 if dialogue also -1)
	if float(opt["writeSpeedCustom"]) < 0.0:
		opt["writeSpeedCustom"] = float(dlg["writeSpeedCustom"])

	# SFX fields
	if opt["sfx"]["spawn"] == "inherit":
		opt["sfx"]["spawn"] = dlg["sfx"]["spawn"]
	if opt["sfx"]["text"] == "inherit":
		opt["sfx"]["text"] = dlg["sfx"]["text"]

	# Background theme
	if opt["backgroundTheme"] == "inherit":
		opt["backgroundTheme"] = dlg["backgroundTheme"]

	# Particles textures
	for k in ["spawn", "text", "ambient"]:
		var tex = opt["particles"][k].get("texture", "inherit")
		if typeof(tex) == TYPE_STRING and tex == "inherit":
			opt["particles"][k]["texture"] = dlg["particles"][k].get("texture", "none")


# -------------------------
# Merge helpers (with {} meaning "inherit subfields")
# -------------------------
func _merge_sfx(base: Dictionary, raw_sfx) -> Dictionary:
	var out := base.duplicate(true)

	# If designer writes "none"/"inherit" as a string, ignore for now (could support later)
	if typeof(raw_sfx) != TYPE_DICTIONARY:
		return out

	var rs: Dictionary = raw_sfx
	if rs.is_empty():
		# {} => keep "inherit" defaults (then inheritance resolver pulls from dialogue)
		return out

	if rs.has("spawn"): out["spawn"] = str(rs["spawn"])
	if rs.has("text"): out["text"] = str(rs["text"])
	return out


func _merge_particles(base: Dictionary, raw_particles) -> Dictionary:
	var out := base.duplicate(true)

	if typeof(raw_particles) != TYPE_DICTIONARY:
		return out

	var rp: Dictionary = raw_particles
	if rp.is_empty():
		# {} => keep inherit defaults (then inheritance resolver pulls from dialogue)
		return out

	for k in ["spawn", "text", "ambient"]:
		if rp.has(k) and typeof(rp[k]) == TYPE_DICTIONARY:
			var rk: Dictionary = rp[k]
			if rk.is_empty():
				# {} at sub-level => do nothing; inheritance stays
				continue
			if rk.has("texture"):
				out[k]["texture"] = str(rk["texture"])
	return out


# -------------------------
# Small utilities
# -------------------------
func _safe_enum(value: String, allowed: Array, fallback: String) -> String:
	return value if allowed.has(value) else fallback

func _read_text_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()

# Optional: resolve final numeric speed used by your typewriter
func resolve_write_speed_chars_per_sec(node: Dictionary) -> float:
	var custom := float(node.get("writeSpeedCustom", -1.0))
	if custom >= 0.0:
		return custom
	var preset := str(node.get("writeSpeed", "medium")).to_lower()
	return float(DialogueDefaults.WRITE_SPEED_PRESETS.get(preset, DialogueDefaults.WRITE_SPEED_PRESETS["medium"]))
