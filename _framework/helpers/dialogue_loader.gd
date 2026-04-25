extends Node
class_name DialogueLoader
## Helper script for loading dialogue files into the game.
## Dialogue files can be found in "dialogue_loader/<npc_name>/"

# TODO: rename writeSpeed to writeSpeedPreset
# TODO: rename writeSpeedCustom to writeSpeed

## Loads a single dialogue node file. Returns a dialogue object with all settings.
static func loadDialogueNodeFile(path: String) -> Dictionary:
	var jsonData := _readTextFile(path)
	if jsonData == "":
		printerr("DialogueLoader: Missing/empty file: %s" % path)
		return {}

	var configuredAttributes = JSON.parse_string(jsonData)
	if typeof(configuredAttributes) != TYPE_DICTIONARY:
		printerr("DialogueLoader: Expected a JSON object at root: %s" % path)
		return {}

	return _fillDialogueMissingFields(configuredAttributes)

## [b]Internal-use only.[/b]  Fills in any missing fields from the dialogue node file with default values.
static func _fillDialogueMissingFields(configuredAttributes: Dictionary) -> Dictionary:
	var dialogue:Dictionary = DialogueDefaults.DEFAULT_DIALOGUE.duplicate(true)
	
	# Mandatory fields
	dialogue.text = configuredAttributes.get("text", dialogue.text)
	var configuredOptions:Array = configuredAttributes.get("options", [])
	if typeof(configuredOptions) == TYPE_ARRAY:
		for configuredOption in configuredOptions:
			if typeof(configuredOption) != TYPE_DICTIONARY:
				printerr("DialogueLoader: Item in options field of this dialogue node isn't a dictionary.")
				continue
			
			var opt := _fillOptionMissingFields(configuredOption, dialogue)
			dialogue.options.append(opt)
	else:
		printerr("DialogueLoader: Options field of this dialogue node file isn't an array.")
	
	# Optional fields
	dialogue.textThemePreset = configuredAttributes.get("textThemePreset", dialogue.textThemePreset)
	dialogue.type = _verifyInList(
		configuredAttributes.get("type", dialogue.type).to_lower(),
		DialogueDefaults.DIALOGUE_TYPES,
		dialogue.type
	)
	dialogue.mode = _verifyInList(
		configuredAttributes.get("mode", dialogue.mode).to_lower(),
		DialogueDefaults.DIALOGUE_MODES,
		dialogue.mode
	)
	dialogue.nextOnHecticFailureID = configuredAttributes.get("nextOnHecticFailureID", dialogue.nextOnHecticFailureID)
	
	dialogue.writeSpeed = _verifyInList(
		configuredAttributes.get("writeSpeed", dialogue.writeSpeed).to_lower(),
		DialogueDefaults.WRITE_SPEED_PRESETS.keys(),
		dialogue.writeSpeed
	)
	dialogue.writeSpeedCustom = max(
		configuredAttributes.get("writeSpeedCustom", dialogue.writeSpeedCustom),
		0.0001 #  arbitrary small value. it just shouldn't be zero.
	)
	if dialogue.writeSpeed != "custom":
		dialogue.writeSpeedCustom = DialogueDefaults.WRITE_SPEED_PRESETS[dialogue.writeSpeed]

	if configuredAttributes.has("sfx"):
		dialogue.sfx = _mergeSfxAttributes(dialogue.sfx, configuredAttributes.sfx)
	
	dialogue.backgroundTheme = _verifyInList(
		configuredAttributes.get("backgroundTheme", dialogue.backgroundTheme).to_lower(),
		DialogueDefaults.BACKGROUND_THEME.keys(),
		dialogue.backgroundTheme
	)

	if configuredAttributes.has("particles"):
		dialogue.particles = _mergeParticleAttributes(dialogue.particles, configuredAttributes.particles)

	return dialogue

## [b]Internal-use only.[/b]  Fills in any missing fields from the option object with default values.
static func _fillOptionMissingFields(configuredAttributes: Dictionary, optionOwner: Dictionary) -> Dictionary:
	var option:Dictionary = DialogueDefaults.DEFAULT_OPTION.duplicate(true)

	# Mandatory
	option.text = configuredAttributes.get("text", option.text)
	option.nextID = configuredAttributes.get("nextID", option.nextID)
	
	# Optional
	option.type = _verifyInList(
		configuredAttributes.get("type", option.type).to_lower(),
		DialogueDefaults.OPTION_TYPES,
		option.type
	)
	option.textThemePreset = configuredAttributes.get("textThemePreset", option.textThemePreset)
	
	option.checkFlags = configuredAttributes.get("checkFlags", option.checkFlags)
	option.setFlags = configuredAttributes.get("setFlags", option.setFlags)
		
	option.writeSpeed = _verifyInList(
		configuredAttributes.get("writeSpeed", option.writeSpeed).to_lower(),
		DialogueDefaults.WRITE_SPEED_PRESETS.keys(),
		option.writeSpeed
	)
	option.writeSpeedCustom = max(
		configuredAttributes.get("writeSpeedCustom", option.writeSpeedCustom),
		0.0001 #  arbitrary small value. it just shouldn't be zero.
	)
	
	if configuredAttributes.has("sfx"):
		option.sfx = _mergeSfxAttributes(option.sfx, configuredAttributes.sfx)
		
	option.backgroundTheme = _verifyInList(
		configuredAttributes.get("backgroundTheme", option.backgroundTheme).to_lower(),
		DialogueDefaults.BACKGROUND_THEME.keys(),
		option.backgroundTheme
	)
	
	if configuredAttributes.has("particles"):
		option.particles = _mergeParticleAttributes(option.particles, configuredAttributes.particles)

	option.spawnDelay = configuredAttributes.get("spawnDelay", option.spawnDelay)
	option.lifetime = configuredAttributes.get("lifetime", option.lifetime)
	
	_resolveOptionInheritance(option, optionOwner)

	return option

## [b]Internal-use only.[/b]  Replaces any instance of "inherit" in an option object configuration with the dialogue's corresponding value.
static func _resolveOptionInheritance(option: Dictionary, optionOwner: Dictionary) -> void:
	if option.textThemePreset == "inherit":
		option.textThemePreset = optionOwner.textThemePreset

	if option.writeSpeed == "inherit":
		option.writeSpeed = optionOwner.writeSpeed

	if option.writeSpeedCustom < 0.0:
		option.writeSpeedCustom = optionOwner.writeSpeedCustom
	
	for event in DialogueDefaults.SFX_EVENTS:
		if option.sfx[event] == "inherit":
			option.sfx[event] = optionOwner.sfx[event]

	if option.backgroundTheme == "inherit":
		option.backgroundTheme = optionOwner.backgroundTheme

	# Particles textures
	for event in DialogueDefaults.PARTICLE_EVENTS:
		for attribute in DialogueDefaults.PARTICLE_EVENT_ATTRIBUTES:
			var _attr:String = option.particles[event].get(attribute, "inherit")
			if _attr == "inherit":
				option.particles[event][attribute] = optionOwner.particles[event].get(attribute, "none")

## [b]Internal-use only.[/b]  Helper function to merge the SFX attributes.
static func _mergeSfxAttributes(default: Dictionary, configuredEvents:Dictionary) -> Dictionary:
	if configuredEvents.is_empty():
		return default
	
	var merged:Dictionary = default.duplicate(true)
	for event in DialogueDefaults.SFX_EVENTS:
		if configuredEvents.has(event):
			merged[event] = configuredEvents[event]
	
	return merged

## [b]Internal-use only.[/b]  Helper function to merge the particle attributes.
static func _mergeParticleAttributes(default: Dictionary, configuredParticles:Dictionary) -> Dictionary:
	if configuredParticles.is_empty():
		return default
	
	var merged := default.duplicate(true)
	for event in DialogueDefaults.PARTICLE_EVENTS:
		if configuredParticles.has(event) and typeof(configuredParticles[event]) == TYPE_DICTIONARY:
			if configuredParticles[event].is_empty():
				continue
			
			for attribute in DialogueDefaults.PARTICLE_EVENT_ATTRIBUTES:
				if configuredParticles[event].has(attribute):
					merged[event][attribute] = configuredParticles[event][attribute]
		else:
			printerr("DialogueLoader: Particle event [%s]'s value isn't a dictionary. Value type ID: " % event, typeof(configuredParticles[event]))
	return merged

## [b]Internal-use only.[/b]  Verifies if value is in list. If not, return fallback.
static func _verifyInList(value: String, list: Array, fallback: String) -> String:
	return value if list.has(value) else fallback

## [b]Internal-use only.[/b]  Reads a file at the path. Path needs to include the file.
static func _readTextFile(path: String) -> String:
	if not FileAccess.file_exists(path):
		printerr("DialogueLoader: File does not exist: ", path)
		return ""
	
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("DialogueLoader: Could not open file: ", path)
		return ""
	
	var contents:String = file.get_as_text()
	file.close()
	return contents
