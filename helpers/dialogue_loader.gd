extends Node
class_name DialogueLoader

## Loads a single dialogue node file. Returns a dialogue object with all settings.
static func loadDialogueNodeFile(path: String) -> Dictionary:
	var json_text := _read_text_file(path)
	if json_text == "":
		printerr("DialogueLoader: Missing/empty file: %s" % path)
		return {}

	var dialogue_obj = JSON.parse_string(json_text)
	if typeof(dialogue_obj) != TYPE_DICTIONARY:
		printerr("DialogueLoader: Expected a JSON object at root: %s" % path)
		return {}

	return _fill_dialogue_missing_fields(dialogue_obj)


## Fills in any missing fields from the dialogue node file with default values.
static func _fill_dialogue_missing_fields(dialogue_obj: Dictionary) -> Dictionary:
	var dialogue:Dictionary = DialogueDefaults.default_dialogue()
	
	# Mandatory fields
	dialogue.text = dialogue_obj.get("text", dialogue.text)
	dialogue.font = dialogue_obj.get("font", dialogue.font)
	dialogue.type = _verify_in_list(
		dialogue_obj.get("type", dialogue.type).to_lower(),
		DialogueDefaults.DIALOGUE_TYPES,
		dialogue.type
	)
	dialogue.mode = dialogue_obj.get("mode", dialogue.mode).to_lower()
	
	var dialogue_obj_options:Array = dialogue_obj.get("options", [])
	if typeof(dialogue_obj_options) == TYPE_ARRAY:
		for option_obj in dialogue_obj_options:
			if typeof(option_obj) != TYPE_DICTIONARY:
				printerr("DialogueLoader: Item in options field of this dialogue node isn't a dictionary.")
				continue
			
			var opt := _fill_option_missing_fields(option_obj, dialogue)
			dialogue.options.append(opt)
	else:
		printerr("DialogueLoader: Options field of this dialogue node file isn't an array.")

	# Optional fields
	dialogue.writeSpeed = _verify_in_list(
		dialogue_obj.get("writeSpeed", dialogue.writeSpeed).to_lower(),
		DialogueDefaults.WRITE_SPEED_PRESETS.keys(),
		dialogue.writeSpeed
	)
	dialogue.writeSpeedCustom = max(
		dialogue_obj.get("writeSpeedCustom", dialogue.writeSpeedCustom),
		0.0001 #  arbitrary small value. it just shouldn't be zero.
	)

	if dialogue_obj.has("sfx"):
		dialogue.sfx = _merge_sfx(dialogue.sfx, dialogue_obj.sfx)
	
	dialogue.backgroundTheme = _verify_in_list(
		dialogue_obj.get("backgroundTheme", dialogue.backgroundTheme).to_lower(),
		DialogueDefaults.BACKGROUND_THEME.keys(),
		dialogue.backgroundTheme
	)

	if dialogue_obj.has("particles"):
		dialogue.particles = _merge_particles(dialogue.particles, dialogue_obj.particles)

	return dialogue

## Fills in any missing fields from the option object with default values.
static func _fill_option_missing_fields(option_obj: Dictionary, dialogue_owner: Dictionary) -> Dictionary:
	var option:Dictionary = DialogueDefaults.default_option()

	# Mandatory
	option.text = option_obj.get("text", option.text)
	option.type = _verify_in_list(
		option_obj.get("type", option.type).to_lower(),
		DialogueDefaults.OPTION_TYPES,
		option.type
	)
	option.nextID = option_obj.get("nextID", option.nextID)
	
	# Optional
	option.font = option_obj.get("font", option.font)
		
	option.writeSpeed = _verify_in_list(
		option_obj.get("writeSpeed", option.writeSpeed).to_lower(),
		DialogueDefaults.WRITE_SPEED_PRESETS.keys(),
		option.writeSpeed
	)
	option.writeSpeedCustom = max(
		option_obj.get("writeSpeedCustom", option.writeSpeedCustom),
		0.0001 #  arbitrary small value. it just shouldn't be zero.
	)
	
	if option_obj.has("sfx"):
		option.sfx = _merge_sfx(option.sfx, option_obj.sfx)
		
	option.backgroundTheme = _verify_in_list(
		option_obj.get("backgroundTheme", option.backgroundTheme).to_lower(),
		DialogueDefaults.BACKGROUND_THEME.keys(),
		option.backgroundTheme
	)
	
	if option_obj.has("particles"):
		option.particles = _merge_particles(option.particles, option_obj.particles)

	option.spawnDelay = option_obj.get("spawnDelay", option.spawnDelay)
	option.lifetime = option_obj.get("lifetime", option.lifetime)
	
	_resolve_option_inheritance(option, dialogue_owner)

	return option


## Replaces any instance of "inherit" in an option object configuration with the dialogue's corresponding value.
static func _resolve_option_inheritance(option: Dictionary, dialogue_owner: Dictionary) -> void:
	if option.font == "inherit":
		option.font = dialogue_owner.font

	if option.writeSpeed == "inherit":
		option.writeSpeed = dialogue_owner.writeSpeed

	if option.writeSpeedCustom < 0.0:
		option.writeSpeedCustom = dialogue_owner.writeSpeedCustom
	
	for event in DialogueDefaults.SFX_EVENTS:
		if option.sfx[event] == "inherit":
			option.sfx[event] = dialogue_owner.sfx[event]

	if option.backgroundTheme == "inherit":
		option.backgroundTheme = dialogue_owner.backgroundTheme

	# Particles textures
	for event in DialogueDefaults.PARTICLE_EVENTS:
		for attribute in DialogueDefaults.PARTICLE_EVENT_ATTRIBUTES:
			var _attr:String = option.particles[event].get(attribute, "inherit")
			if _attr == "inherit":
				option.particles[event][attribute] = dialogue_owner.particles[event].get(attribute, "none")

## Helper function to merge the SFX attributes.
static func _merge_sfx(default: Dictionary, sfx_obj) -> Dictionary:
	if typeof(sfx_obj) != TYPE_DICTIONARY:
		return default

	if sfx_obj.is_empty():
		return default
	
	var merged:Dictionary = default.duplicate(true)
	for event in DialogueDefaults.SFX_EVENTS:
		if sfx_obj.has(event):
			merged[event] = sfx_obj[event]
	
	return merged

## Helper function to merge the particle attributes.
static func _merge_particles(default: Dictionary, particles_obj) -> Dictionary:
	if typeof(particles_obj) != TYPE_DICTIONARY:
		return default

	if particles_obj.is_empty():
		return default
	
	var merged := default.duplicate(true)
	for event in DialogueDefaults.PARTICLE_EVENTS:
		if particles_obj.has(event) and typeof(particles_obj[event]) == TYPE_DICTIONARY:
			if particles_obj[event].is_empty():
				continue
			
			for attribute in DialogueDefaults.PARTICLE_EVENT_ATTRIBUTES:
				if particles_obj[event].has(attribute):
					merged[event][attribute] = particles_obj[event][attribute]
		else:
			printerr("DialogueLoader: Particle event [%s]'s value isn't a dictionary. Value type ID: " % event, typeof(particles_obj[event]))
	return merged


## Verifies if value in in list. If not, return fallback.
static func _verify_in_list(value: String, list: Array, fallback: String) -> String:
	return value if list.has(value) else fallback

## Reads a file at the path. Path needs to include the file.
static func _read_text_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		printerr("DialogueLoader: File does not exist: ", path)
		return ""
	
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("DialogueLoader: Could not open file: ", path)
		return ""
	
	return file.get_as_text()

# Optional: resolve final numeric speed used by your typewriter
func resolve_write_speed_chars_per_sec(node: Dictionary) -> float:
	var custom := float(node.get("writeSpeedCustom", -1.0))
	if custom >= 0.0:
		return custom
	var preset := str(node.get("writeSpeed", "medium")).to_lower()
	return float(DialogueDefaults.WRITE_SPEED_PRESETS.get(preset, DialogueDefaults.WRITE_SPEED_PRESETS["medium"]))
