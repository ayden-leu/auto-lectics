extends Node
class_name DialogueLoader
## Helper script for loading dialogue files into the game.
## Dialogue files can be found in "dialogue_loader/<npc_name>/"

# TODO: rename writeSpeed to writeSpeedPreset
# TODO: rename writeSpeedCustom to writeSpeed

## Determines the file type of the dialogue objects.
const DIALOGUE_FILE_TYPE = ".json"
## Determines the file name of an NPC's default dialogue attributes.
const DEFAULT_DIALOGUE_ID:String = "_default_dialogue"
## Determines the file name of an NPC's default option attributes.
const DEFAULT_OPTION_ID:String = "_default_option"

## Gets the path to a dialogue object.
static func assemblePath(entityName:String, id:String) -> String:
	return FR_Globals.STORAGE_PATH.DIALOGUE + entityName + "/" + id + DIALOGUE_FILE_TYPE

## Loads a single dialogue node file. Returns a dialogue object with all settings.
static func loadDialogueNodeFile(path: String, reportError:bool = true) -> Dictionary:
	var jsonData := _readTextFile(path, reportError)
	if jsonData == "":
		if reportError: printerr("DialogueLoader: Missing/empty file: %s" % path)
		return {}

	var configuredAttributes = JSON.parse_string(jsonData)
	if typeof(configuredAttributes) != TYPE_DICTIONARY:
		if reportError: printerr("DialogueLoader: Expected a JSON object at root: %s" % path)
		return {}

	return configuredAttributes


static func fillNpcDialogueDefaults(base:Dictionary, defaultDialogue:Dictionary, defaultOption:Dictionary) -> Dictionary:
	var copy:Dictionary = defaultDialogue.duplicate(true)
	
	if base.has("text"):
		copy.text = base.text
		
	if base.has("options"):
		copy.options = base.options
		
	if base.has("type"):
		copy.type = base.type
		
	if base.has("mode"):
		copy.mode = base.mode
		if base.mode == "hectic":
			if base.has("nextOnHecticFailureID"):
				copy.nextOnHecticFailureID = base.nextOnHecticFailureID
			else:
				printerr("DialogueLoader:  Base doesn't have nextOnHecticFailureID when it should.")
		
	if base.has("textThemePreset"):
		copy.textThemePreset = base.textThemePreset
		
	if base.has("writeSpeed"):
		copy.writeSpeed = base.writeSpeed
		if base.writeSpeed == "custom":
			if base.has("writeSpeedCustom"):
				copy.writeSpeedCustom = base.writeSpeedCustom
			else:
				printerr("DialogueLoader:  Base doesn't have writeSpeedCustom when it should.")
	
	if base.has("sfx"):
		copy.sfx = _mergeSfxAttributes(base.sfx, copy.get("sfx", {}))
	
	if base.has("options"):
		copy.options = []
		for option in base.options:
			copy.options.push_back(
				_fillNpcOptionDefaults(option, defaultOption)
			)
	
	return copy

static func _fillNpcOptionDefaults(base:Dictionary, defaults:Dictionary) -> Dictionary:
	var copy:Dictionary = defaults.duplicate(true)
	
	if base.has("text"):
		copy.text = base.text
	
	if base.has("nextID"):
		copy.nextID = base.nextID
	
	if base.has("type"):
		copy.type = base.type
	
	if base.has("textThemePreset"):
		copy.textThemePreset = base.textThemePreset
	
	if base.has("writeSpeed"):
		copy.writeSpeed = base.writeSpeed
	
	if base.has("writeSpeedCustom"):
		copy.writeSpeedCustom = base.writeSpeedCustom
	
	if base.has("checkFlags"):
		copy.checkFlags = base.checkFlags
	
	if base.has("setFlags"):
		copy.setFlags = base.setFlags
	
	if base.has("sfx"):
		copy.sfx = _mergeSfxAttributes(base.sfx, copy.get("sfx", {}))

	if base.has("spawnDelay"):
		copy.spawnDelay = base.spawnDelay
	
	if base.has("lifetime"):
		copy.lifetime = base.lifetime
	
	return copy

## [b]Internal-use only.[/b]  Fills in any missing fields from the dialogue node file with default values.
static func fillDialogueMissingFields(configuredAttributes: Dictionary) -> Dictionary:
	var dialogue:Dictionary = DialogueDefaults.DEFAULT_DIALOGUE.duplicate(true)
	
	dialogue.text = configuredAttributes.get("text", dialogue.text)
	
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

	option.spawnDelay = configuredAttributes.get("spawnDelay", option.spawnDelay)
	option.lifetime = configuredAttributes.get("lifetime", option.lifetime)
	
	_resolveOptionInheritance(option, optionOwner)

	return option

## [b]Internal-use only.[/b]  Replaces any instance of "inherit" in an option object configuration with the dialogue's corresponding value.
static func _resolveOptionInheritance(option: Dictionary, optionOwner: Dictionary) -> void:
	print("AAAA")
	print(option)
	print()
	print(optionOwner)
	if option.textThemePreset == "inherit":
		option.textThemePreset = optionOwner.textThemePreset

	if option.writeSpeed == "inherit":
		option.writeSpeed = optionOwner.writeSpeed

	if option.writeSpeedCustom < 0.0:
		option.writeSpeedCustom = optionOwner.writeSpeedCustom
	
	for event in DialogueDefaults.SFX_EVENTS:
		#print(option.sfx[event])
		#print()
		#print(optionOwner.sfx[event])
		if option.sfx[event] == "inherit":
			option.sfx[event] = optionOwner.sfx[event]

## [b]Internal-use only.[/b]  Helper function to merge the SFX attributes.
static func _mergeSfxAttributes(default: Dictionary, configuredEvents:Dictionary) -> Dictionary:
	if configuredEvents.is_empty():
		return default
	
	var merged:Dictionary = default.duplicate(true)
	for event in DialogueDefaults.SFX_EVENTS:
		if configuredEvents.has(event):
			merged[event] = configuredEvents[event]
	
	return merged

## [b]Internal-use only.[/b]  Verifies if value is in list. If not, return fallback.
static func _verifyInList(value: String, list: Array, fallback: String) -> String:
	return value if list.has(value) else fallback

## [b]Internal-use only.[/b]  Reads a file at the path. Path needs to include the file.
static func _readTextFile(path: String, reportError:bool = true) -> String:
	if not FileAccess.file_exists(path):
		if reportError: printerr("DialogueLoader: File does not exist: ", path)
		return ""
	
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		if reportError: printerr("DialogueLoader: Could not open file: ", path)
		return ""
	
	var contents:String = file.get_as_text()
	file.close()
	return contents
