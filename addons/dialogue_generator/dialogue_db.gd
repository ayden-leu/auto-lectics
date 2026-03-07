extends RefCounted
class_name DialogueDB

var dialogues: Array[Dictionary] = []
var by_id: Dictionary = {}

func _ready() -> void:
	printerr("WARNING: small aspects about dialogue_db.gd might not be up-to-date. Use at your own risk.")

# ----------------------------
# Schema defaults (match your project needs)
# ----------------------------
const DIALOGUE_DEFAULTS := {
	"text": "",
	"font":"default",
	"type": "Neutral",   # Neutral/Happy/Angry/Confused/Sad
	"mode": "Normal",    # Normal/Hectic
	"nextOnHecticFailureID": "",
	"writeSpeed": "medium",
	"writeSpeedCustom": -1,
	
	"sfx": {
		"spawn": "default",
		"text": "default",
	},
	
	"backgroundTheme": "default",
	"particles": {
		"spawn": {
			"texture": "none",
		},
		"text": {
			"texture": "none",
		},
		"ambient": {
			"texture": "none",
		},
	},
	"options": []
}

const OPTION_DEFAULTS := {
	"prerequest": [],
	"text": "",
	"font": "inherit",
	"type": "Neutral",
	"writeSpeed": "inherit",
	"writeSpeedCustom": -1,
	"sfx": {
		"spawn": "none",
		"text": "inherit",
	},
	"backgroundTheme": "inherit",
	"particles": {
		"spawn": {
			"texture": "none",
		},
		"text": {
			"texture": "inherit",
		},
		"ambient": {
			"texture": "inherit",
		},
	},
	"spawnDelay": 0.5,
	"lifetime": -1,
	"nextID": ""
}

const DIALOGUE_TYPES := ["Neutral", "Happy", "Angry", "Confused", "Sad"]
const DIALOGUE_MODES := ["Normal", "Hectic"]
const OPTION_TYPES := ["Positive", "Neutral", "Negative"]

func rebuild_index() -> void:
	by_id.clear()
	for d in dialogues:
		var id := str(d.get("id", ""))
		if id != "":
			by_id[id] = d

static  func get_json_dir() -> String:
	var dir := Globals.STORAGE_PATH.DIALOGUE
	DirAccess.make_dir_absolute(dir)
	return dir
	
static func get_json_path(default_name := "NPC1") -> String:
	return get_json_dir().path_join(default_name)
	
static func list_json_files(dir_path: String)-> Array[String]:
	var out:Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
		
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
	
func load_or_create(path : String) -> Array:
	if FileAccess.file_exists(path):
		var f := FileAccess.open(path,FileAccess.READ)
		if f == null:
			push_error("Failed to open: %s" %path)
			return []
		var parsed := JSON.parse_string(f.get_as_text())
		if typeof(parsed) != TYPE_ARRAY:
			push_error("Root JSON must be an array.")
			return []
		f.close()
		return parsed
	else:
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f != null:
			f. store_string(JSON.stringify([],"\t"))
		f.flush()
		f.close()
		return []
		
func save(path : String, dialogues: Array) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("Failed to write: %s" %path)
		return
	f.store_string(JSON.stringify(dialogues, "\t"))
	print("Saved: ", path)
	f.flush()
	f.close()
	
func find_dialogue(dialogues: Array, did: String) -> Dictionary:
	for d in dialogues:
		if typeof(d) == TYPE_DICTIONARY and str(d.get("id","")) == did:
			return d
	return {} 
	
func ensure_list(obj: Dictionary, key: String) -> void:
	if not obj.has(key) or typeof(obj[key]) != TYPE_ARRAY:
		obj[key] = []

func resolve_defaults_dialogue(d: Dictionary) -> Dictionary:
	var out := {}
	out["id"] = d.get("id", "")
	out["text"] = d.get("text", DIALOGUE_DEFAULTS["text"])
	out["type"] = d.get("type", DIALOGUE_DEFAULTS["type"])
	out["mode"] = d.get("mode", DIALOGUE_DEFAULTS["mode"])
	out["nextOnHecticFailureID"] = d.get("nextOnHecticFailureID", DIALOGUE_DEFAULTS["nextOnHecticFailureID"])
	out["options"] = d.get("options", DIALOGUE_DEFAULTS["options"])

	out["writeSpeed"] = d.get("writeSpeed", DIALOGUE_DEFAULTS["writeSpeed"])
	out["writeSpeedCustom"] = d.get("writeSpeedCustom", DIALOGUE_DEFAULTS["writeSpeedCustom"])
	out["font"] = d.get("font", DIALOGUE_DEFAULTS["font"])
	out["sfx"] = d.get("sfx", DIALOGUE_DEFAULTS["sfx"])
	out["backgroundTheme"] = d.get("backgroundTheme", DIALOGUE_DEFAULTS["backgroundTheme"])
	out["particles"] = d.get("particles", DIALOGUE_DEFAULTS["particles"])
	return out
	
func resolve_defaults_option(o: Dictionary, parent: Dictionary) -> Dictionary:
	var out := {}
	out["prerequest"] = o.get("prerequest", OPTION_DEFAULTS["prerequest"])
	out["text"] = o.get("text", OPTION_DEFAULTS["text"])
	out["type"] = o.get("type", OPTION_DEFAULTS["type"])
	out["writeSpeed"] = o.get("writeSpeed", OPTION_DEFAULTS["writeSpeed"])
	out["writeSpeedCustom"] = o.get("writeSpeedCustom", OPTION_DEFAULTS["writeSpeedCustom"])
	out["nextID"] = o.get("nextID", OPTION_DEFAULTS["nextID"])
	out["lifetime"] = o.get("lifetime", OPTION_DEFAULTS["lifetime"])
	out["sfx"] = o.get("sfx", OPTION_DEFAULTS["sfx"])
	out["backgroundTheme"] = o.get("backgroundTheme", OPTION_DEFAULTS["backgroundTheme"])
	out["particles"] = o.get("particles", OPTION_DEFAULTS["particles"])
	out["spawnDelay"] = o.get("spawnDelay", OPTION_DEFAULTS["spawnDelay"])
	return out
	
func clean_defaults_option(o: Dictionary) -> Dictionary:
	var out := {}

	for k in ["prerequest","text","type","font","writeSpeed","writeSpeedCustom",
			  "backgroundTheme","spawnDelay","lifetime","nextID"]:
		var dv = OPTION_DEFAULTS[k]
		var v = o.get(k, dv)
		if v != dv:
			out[k] = v

	# sfx
	var sfx = o.get("sfx", OPTION_DEFAULTS["sfx"])
	if typeof(sfx) == TYPE_DICTIONARY:
		var sfx_out := {}
		var spawn_sfx = sfx.get("spawn", OPTION_DEFAULTS["sfx"]["spawn"])
		var text_sfx = sfx.get("text", OPTION_DEFAULTS["sfx"]["text"])
		if spawn_sfx != OPTION_DEFAULTS["sfx"]["spawn"]:
			sfx_out["spawn"] = spawn_sfx
		if text_sfx != OPTION_DEFAULTS["sfx"]["text"]:
			sfx_out["text"] = text_sfx
		if not sfx_out.is_empty():
			out["sfx"] = sfx_out

	# particles
	var particles = o.get("particles", OPTION_DEFAULTS["particles"])
	if typeof(particles) == TYPE_DICTIONARY:
		var par_out := {}
		for key in ["spawn","text","ambient"]:
			var p = particles.get(key, {})
			var dp = OPTION_DEFAULTS["particles"].get(key, {})
			if typeof(p) == TYPE_DICTIONARY and typeof(dp) == TYPE_DICTIONARY:
				var p_out := {}
				var pv = p.get("texture", dp.get("texture"))
				var dpv = dp.get("texture")
				if pv != dpv:
					p_out["texture"] = pv
				if not p_out.is_empty():
					par_out[key] = p_out
		if not par_out.is_empty():
			out["particles"] = par_out

	return out

func clean_defaults_dialogue(d: Dictionary) -> Dictionary:
	var out := {"id": d["id"]}
	var opts: Array = d.get("options", [])
	out["options"] = []
	for o in opts:
		if typeof(o) == TYPE_DICTIONARY:
			out["options"].append(clean_defaults_option(o))

	# sfx block
	if d.has("sfx") and typeof(d["sfx"]) == TYPE_DICTIONARY:
		var sfx := d.get("sfx")
		var sfx_out := {}
		var spawn_sfx = sfx.get("spawn", DIALOGUE_DEFAULTS["sfx"]["spawn"])
		var text_sfx = sfx.get("text", DIALOGUE_DEFAULTS["sfx"]["text"])
		if spawn_sfx != DIALOGUE_DEFAULTS["sfx"]["spawn"]:
			sfx_out["spawn"] = spawn_sfx
		if text_sfx != DIALOGUE_DEFAULTS["sfx"]["text"]:
			sfx_out["text"] = text_sfx
		if not sfx_out.is_empty():
			out["sfx"] = sfx_out

	# particles block (same logic as Python)
	if d.has("particles") and typeof(d["particles"]) == TYPE_DICTIONARY:
		var particles := d.get("particles")
		var par_out := {}
		for key in ["spawn", "text", "ambient"]:
			var p = particles.get(key, {})
			var dp = DIALOGUE_DEFAULTS["particles"].get(key, {})
			if typeof(p) == TYPE_DICTIONARY and typeof(dp) == TYPE_DICTIONARY:
				var p_out := {}
				var pv = p.get("texture", dp.get("texture"))
				var dpv = dp.get("texture")
				if pv != dpv:
					p_out["texture"] = pv
				if not p_out.is_empty():
					par_out[key] = p_out
		if not par_out.is_empty():
			out["particles"] = par_out

	# simple fields
	for k in ["text","font","type","mode","nextOnHecticFailureID","writeSpeed","writeSpeedCustom","backgroundTheme"]:
		var dv = DIALOGUE_DEFAULTS[k]
		var v = d.get(k, dv)
		if v != dv:
			out[k] = v

	return out

func list_dialogues(dialogues: Array) -> void:
	if dialogues.is_empty():
		print("(No dialogues yet)")
		return
	dialogues.sort_custom(func(a,b): return str(a.get("id","")) < str(b.get("id","")))
	for d in dialogues:
		var rd := resolve_defaults_dialogue(d)
		var preview := str(rd["text"]).replace("\n"," ")
		if preview.length() > 60:
			preview = preview.substr(0,60) + "…"
		var opts: Array = d.get("options", [])
		print("id='%s' type=%s mode=%s options=%d text='%s'" % [rd["id"], rd["type"], rd["mode"], opts.size(), preview])

func validate(dialogues: Array) -> Array[String]:
	var warnings: Array[String] = []
	var ids: Array[String] = []
	for d in dialogues:
		ids.append(str(d.get("id","")))

	# missing/empty ids
	for id in ids:
		if id == "":
			warnings.append("Some dialogues have missing/empty id.")
			break

	# duplicates
	var seen := {}
	for id in ids:
		if seen.has(id):
			warnings.append("Duplicate dialogue id: %s" % id)
		seen[id] = true

	var id_set := {}
	for id in ids:
		id_set[id] = true

	for d in dialogues:
		var rd := resolve_defaults_dialogue(d)
		var did := str(rd["id"])

		if not DIALOGUE_TYPES.has(str(rd["type"])):
			warnings.append("Dialogue '%s' invalid type '%s'" % [did, rd["type"]])

		ensure_list(d, "options")
		for o_any in d["options"]:
			if typeof(o_any) != TYPE_DICTIONARY:
				continue
			var ro := resolve_defaults_option(o_any, d)

			if not OPTION_TYPES.has(str(ro["type"])):
				warnings.append("Dialogue '%s' option '%s' invalid type '%s'" % [did, ro["text"], ro["type"]])

			var sd = ro["spawnDelay"]
			if typeof(sd) not in [TYPE_INT, TYPE_FLOAT]:
				warnings.append("Dialogue '%s' option '%s' spawnDelay must be number" % [did, ro["text"]])

			var nxt := str(ro["nextID"])
			if nxt != "" and not id_set.has(nxt):
				warnings.append("Dialogue '%s' option '%s' nextID '%s' does not exist" % [did, ro["text"], nxt])

			var life = ro["lifetime"]
			if typeof(life) not in [TYPE_INT, TYPE_FLOAT]:
				warnings.append("Dialogue '%s' option '%s' lifetime must be number" % [did, ro["text"]])

	return warnings

func add_dialogue(dialogues: Array, did: String, text: String = "", dtype: String = "Neutral", mode: String = "normal") -> bool:
	if find_dialogue(dialogues, did) != {}:
		return false
	var d := DIALOGUE_DEFAULTS.duplicate(true)
	d["id"] = did
	d["text"] = text
	d["type"] = dtype
	d["mode"] = mode
	dialogues.append(d)
	return true

func delete_dialogue(dialogues: Array, did: String) -> bool:
	for i in range(dialogues.size() - 1, -1, -1):
		var d = dialogues[i]
		if typeof(d) == TYPE_DICTIONARY and str(d.get("id", "")) == did:
			dialogues.remove_at(i)
			return true
	return false
	
func load_json(path: String) -> bool:
	dialogues = load_or_create(path)
	# Ensure dictionaries only
	var cleaned: Array[Dictionary] = []
	for x in dialogues:
		if typeof(x) == TYPE_DICTIONARY:
			cleaned.append(x)
	dialogues = cleaned
	rebuild_index()
	return true

func save_json(path: String, clean_defaults := true) -> bool:
	var out: Array = dialogues
	if clean_defaults:
		var tmp: Array = []
		for d in dialogues:
			tmp.append(clean_defaults_dialogue(d))
		out = tmp
	save(path, out)
	return true

func add_option_to_dialogue(d: Dictionary, text: String, otype: String = "Neutral", next_id: String = "") -> void:
	ensure_list(d, "options")
	var opt := OPTION_DEFAULTS.duplicate(true)
	opt["text"] = text
	opt["type"] = otype
	opt["nextID"] = next_id
	d["options"].append(opt)
