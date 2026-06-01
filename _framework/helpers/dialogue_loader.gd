@icon("uid://id471bfglpdp")
extends Node
class_name DialogueLoader
## Loads dialogue JSON files and fills in missing dialogue fields.
##
## This helper class converts dialogue JSON files into fully configured dialogue
## dictionaries that can be used by dialogue-related systems such as
## [DialogueConsole] and [InteractableNPC].
##
##
##
## [br][br][br]
## [b]Use Case[/b][br]
## This class is used whenever a dialogue node needs to be loaded from a dialogue
## tree. It handles reading the JSON file, applying NPC-specific defaults, and
## filling any remaining missing fields with [DialogueDefaults].
##
##
##
## [br][br][br]
## [b]How to Use[/b][br]
## Call [method getDialogueNode] with the dialogue tree ID and the dialogue node
## ID you want to load. Dialogue files should be stored under [constant STORAGE_PATH]
## in subfolders whose name will be the dialogue tree ID.
## The files should also use the [constant DIALOGUE_FILE_TYPE] file extension.
##
##
##
## [br][br][br]
## [b]Default Files[/b][br]
## Each dialogue tree folder may optionally include [constant DEFAULT_DIALOGUE_ID].[constant DIALOGUE_FILE_TYPE]
## and [constant DEFAULT_OPTION_ID].[constant DIALOGUE_FILE_TYPE].
## The former is currently [code]_default_dialogue.json[/code] and the latter is
## currently [code]_default_option.json[/code].
## [br][br]
## These files define NPC-specific defaults that are applied before the global defaults in [DialogueDefaults].
##
##
##
## [br][br][br]
## [b]Important Notes[/b][br]
## This class only loads and prepares dialogue data. It does not display dialogue,
## spawn options, update story flags, or run dialogue events.
## [br][br]
## Dialogue flow is handled by [InteractableNPC], while dialogue display, option
## selection, commands, and story flag updates are handled by [DialogueConsole].
## Dialogue-related windows are created and managed through [WindowManager].

# TODO: rename writeSpeed to writeSpeedPreset
# TODO: rename writeSpeedCustom to writeSpeed

## The storage location of all dialogue trees.
## [br]
## Dialogue folders should be placed inside this directory.
## The name of the folder corresponds to the dialogue tree ID.
## [br][br]
const STORAGE_PATH:String = "res://dialogue_trees/"

## Determines the file type of the dialogue objects.
## [br]
## Dialogue files are expected to use this file extension.
## [br][br]
const DIALOGUE_FILE_TYPE:String = ".json"

## Determines the file name of an NPC's default dialogue attributes.
## [br]
## If this file exists in a dialogue tree ID folder, its values are used as
## NPC-specific defaults for dialogue nodes in that folder.
## [br][br]
const DEFAULT_DIALOGUE_ID:String = "_default_dialogue"

## Determines the file name of an NPC's default option attributes.
## [br]
## If this file exists in a dialogue tree ID folder, its values are used as
## NPC-specific defaults for options in that folder.
## [br][br]
const DEFAULT_OPTION_ID:String = "_default_option"

## [b]Internal-use Only.[/b][br]
## Used for error returns since an empty [Dictionary] can mean something and
## a typed [Dictionary] variable can't be [code]null[/code].
const _ERROR_DICT:Dictionary[String, Variant] = {"error": null}


## Loads a dialogue node for a given entity and dialogue ID.
## [br][br]
## This is the main function other scripts should use when requesting dialogue
## data. It loads the requested dialogue JSON file, applies optional NPC-specific
## defaults, then fills any remaining missing fields using [DialogueDefaults].
## [br][br]
## If the requested dialogue file cannot be loaded, the fallback dialogue file is
## loaded instead.
## [br][br]
## [param entityName] is the name of the dialogue folder to load from.
## [param id] is the dialogue file ID without the [constant DIALOGUE_FILE_TYPE] extension.
## [br][br]
## Returns a fully configured dialogue dictionary.
static func getDialogueNode(dialogueTreeID:String, id: String) -> Dictionary:
	var topPath:String = assemblePath(dialogueTreeID, id)
	var top:Dictionary = loadDialogueNodeFile(topPath)
	if top == _ERROR_DICT:
		DebugHud.addToLog("DialougeLoader: Failed to load dialogue ID '%s' at '%s'" % [id, topPath], DebugHud.LogType.ERROR)
		top = loadDialogueNodeFile(
			STORAGE_PATH + "fallback" + DIALOGUE_FILE_TYPE
		)

	var npcDialogueDefaultsPath:String = assemblePath(dialogueTreeID, DEFAULT_DIALOGUE_ID)
	var npcDialogueDefaults:Dictionary = loadDialogueNodeFile(npcDialogueDefaultsPath, false)
	if npcDialogueDefaults == _ERROR_DICT:
		DebugHud.addToLog("DialogueLoader: No default dialogue attribute file found for dialogue tree ID '%s' at '%s'" % [dialogueTreeID, topPath], DebugHud.LogType.WARNING)

	var npcOptionDefaultsPath:String = assemblePath(dialogueTreeID, DEFAULT_OPTION_ID)
	var npcOptionDefaults:Dictionary = loadDialogueNodeFile(npcOptionDefaultsPath, false)
	if npcOptionDefaults == _ERROR_DICT:
		DebugHud.addToLog("DialogueLoader: No default option attribute file found for dialogue tree ID '%s' at '%s'" % [dialogueTreeID, topPath], DebugHud.LogType.WARNING)

	var withNpcDefaults:Dictionary = fillNpcDialogueDefaults(top, npcDialogueDefaults, npcOptionDefaults)

	var result:Dictionary = fillDialogueMissingFields(withNpcDefaults)

	return result

## Gets the path to a dialogue object.
## [br][br]
## [param entityName] is the name of the dialogue folder to load from.
## [param id] is the dialogue file ID without the [constant DIALOGUE_FILE_TYPE] extension.
## [br][br]
## Returns the full path to the dialogue file.
static func assemblePath(entityName:String, id:String) -> String:
	return STORAGE_PATH + entityName + "/" + id + DIALOGUE_FILE_TYPE

## Loads a single dialogue node file.
## [br][br]
## Reads a JSON file at the given path and returns its root dictionary.
## [br][br]
## [param path] should include the full file path and file extension.
## [param reportError] controls whether loading errors should be printed.
## [br][br]
## Returns [constant _ERROR_DICT] if the file is missing, empty, invalid, or if the
## JSON root is not a dictionary.
static func loadDialogueNodeFile(path: String, reportError:bool = true) -> Dictionary:
	var jsonData := _readTextFile(path, reportError)
	if jsonData == "":
		if reportError:
			DebugHud.addToLog("DialogueLoader: Missing/empty file: %s" % path, DebugHud.LogType.WARNING)
		return _ERROR_DICT

	var parsedData = JSON.parse_string(jsonData)
	if typeof(parsedData) != TYPE_DICTIONARY:
		if reportError:
			DebugHud.addToLog("DialogueLoader: Expected a JSON object at root: %s" % path, DebugHud.LogType.WARNING)
		return _ERROR_DICT

	return parsedData


## Applies NPC-specific default dialogue and option values to a dialogue object.
## [br][br]
## This function is used before [method fillDialogueMissingFields]. It first
## duplicates the NPC-specific dialogue defaults, then overwrites those values
## with any fields found in [param base]. Options are also passed through
## [method _fillNpcOptionDefaults] so NPC-specific option defaults can be applied.
## [br][br]
## [param base] is the dialogue dictionary loaded from the requested dialogue file.
## [param defaultDialogue] is the NPC-specific default dialogue dictionary.
## [param defaultOption] is the NPC-specific default option dictionary.
## [br][br]
## Returns a dialogue dictionary with NPC-specific defaults applied.
static func fillNpcDialogueDefaults(base:Dictionary, defaultDialogue:Dictionary, defaultOption:Dictionary) -> Dictionary:
	var copy:Dictionary = defaultDialogue.duplicate(true)

	if base.has("text"):
		copy.text = base.text

	if base.has("type"):
		copy.type = base.type

	if base.has("mode"):
		copy.mode = base.mode
		if base.mode == "hectic":
			if base.has("nextOnHecticFailureID"):
				copy.nextOnHecticFailureID = base.nextOnHecticFailureID
			else:
				DebugHud.addToLog("DialogueLoader:  Base doesn't have nextOnHecticFailureID when it should.", DebugHud.LogType.ERROR)
			if base.has("hecticDuration"):
				copy.hecticDuration = base.hecticDuration

	if base.has("textThemePreset"):
		copy.textThemePreset = base.textThemePreset

	if base.has("writeSpeed"):
		copy.writeSpeed = base.writeSpeed
		if base.writeSpeed == "custom":
			if base.has("writeSpeedCustom"):
				copy.writeSpeedCustom = base.writeSpeedCustom
			else:
				DebugHud.addToLog("DialogueLoader:  Base doesn't have writeSpeedCustom when it should.", DebugHud.LogType.ERROR)

	if base.has("sfx"):
		copy.sfx = _mergeSfxAttributes(base.sfx, copy.get("sfx", {}))

	if base.has("options"):
		copy.options = []
		for option in base.options:
			copy.options.push_back(
				_fillNpcOptionDefaults(option, defaultOption)
			)

	return copy

## [b]Internal-use Only.[/b]
## Applies NPC-specific option defaults to a dialogue option.
## [br][br]
## This function duplicates [param defaults], then overwrites those values with
## fields found in [param base].
## [br][br]
## Returns an option dictionary with NPC-specific defaults applied.
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
		# slightly more complicated so engine knows dictionary typess
		var temp:Dictionary[String, bool] = {}
		for flag:String in base.checkFlags:
			temp[flag] = base.checkFlags[flag] as bool
		copy.checkFlags = temp

	if base.has("setFlags"):
		# slightly more complicated so engine knows dictionary typess
		var temp:Dictionary[String, bool] = {}
		for flag:String in base.setFlags:
			temp[flag] = base.setFlags[flag] as bool
		copy.setFlags = temp

	if base.has("allowBack"):
		copy.allowBack = base.allowBack

	if base.has("rejectBackMessage"):
		copy.rejectBackMessage = base.rejectBackMessage

	if base.has("sfx"):
		copy.sfx = _mergeSfxAttributes(base.sfx, copy.get("sfx", {}))

	if base.has("spawnDelay"):
		copy.spawnDelay = base.spawnDelay

	if base.has("lifetime"):
		copy.lifetime = base.lifetime

	return copy

## Fills in any missing fields from the dialogue node file with default values.
## [br][br]
## This function applies the global fallback values stored in
## [member DialogueDefaults.DEFAULT_DIALOGUE] and validates fields such as
## dialogue type, dialogue mode, and write speed.
## [br][br]
## Each option in the dialogue's [code]options[/code] array is also passed through
## [method _fillOptionMissingFields].
## [br][br]
## Returns a fully configured dialogue dictionary.
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

	dialogue.hecticDuration = configuredAttributes.get("hecticDuration", dialogue.hecticDuration)

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
				DebugHud.addToLog("DialogueLoader: Item in options field of this dialogue node isn't a dictionary.", DebugHud.LogType.ERROR)
				continue

			var opt := _fillOptionMissingFields(configuredOption, dialogue)
			dialogue.options.append(opt)
	else:
		DebugHud.addToLog("DialogueLoader: Options field of this dialogue node file isn't an array.", DebugHud.LogType.ERROR)

	return dialogue

## [b]Internal-use Only.[/b]
## Fills in any missing fields from the option object with default values.
## [br][br]
## This function applies the global fallback values stored in
## [member DialogueDefaults.DEFAULT_OPTION] and validates fields such as option
## type and write speed.
## [br][br]
## After the option is filled, inherited values are resolved with
## [method _resolveOptionInheritance].
## [br][br]
## Returns a fully configured option dictionary.
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

	option.allowBack = configuredAttributes.get("allowBack", option.allowBack)
	option.rejectBackMessage = configuredAttributes.get("rejectBackMessage", option.rejectBackMessage)

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

## [b]Internal-use Only.[/b]
## Replaces any instance of [code]inherit[/code] in an option object
## configuration with the dialogue's corresponding value.
## [br][br]
## This is used so options can automatically match the parent dialogue's text
## theme, write speed, and SFX values.
static func _resolveOptionInheritance(option: Dictionary, optionOwner: Dictionary) -> void:
	if option.textThemePreset == "inherit":
		option.textThemePreset = optionOwner.textThemePreset

	if option.writeSpeed == "inherit":
		option.writeSpeed = optionOwner.writeSpeed

	if option.writeSpeedCustom < 0.0:
		option.writeSpeedCustom = optionOwner.writeSpeedCustom

	for event:String in DialogueDefaults.SFX_EVENTS:
		if option.sfx[event] == "inherit":
			option.sfx[event] = optionOwner.sfx[event]

## [b]Internal-use Only.[/b]
## Merges configured SFX values with default SFX values.
## [br][br]
## Only SFX events listed in [member DialogueDefaults.SFX_EVENTS] are checked.
## If [param configuredEvents] contains one of those events, it overrides the
## corresponding value from [param default].
## [br][br]
## Returns a merged SFX dictionary.
static func _mergeSfxAttributes(default: Dictionary, configuredEvents:Dictionary) -> Dictionary:
	if configuredEvents.is_empty():
		return default

	var merged:Dictionary = default.duplicate(true)
	for event in DialogueDefaults.SFX_EVENTS:
		if configuredEvents.has(event):
			merged[event] = configuredEvents[event]

	return merged

## [b]Internal-use Only.[/b]
## Verifies that a value exists in a list of accepted values.
## [br][br]
## If [param value] exists in [param list], it is returned. Otherwise,
## [param fallback] is returned.
static func _verifyInList(value: String, list: Array, fallback: String) -> String:
	return value if list.has(value) else fallback

## [b]Internal-use Only.[/b]
## Reads a text file at a given path.
## [br][br]
## [param path] needs to include the full file path and file extension.
## [param reportError] controls whether file access errors should be printed.
## [br][br]
## Returns the file contents as a [String]. Returns an empty string if the file
## does not exist or cannot be opened.
static func _readTextFile(path: String, reportError:bool = true) -> String:
	if not FileAccess.file_exists(path):
		if reportError:
			DebugHud.addToLog("DialogueLoader: File does not exist: '%s'" % path, DebugHud.LogType.ERROR)
		return ""

	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		if reportError: DebugHud.addToLog("DialogueLoader: Could not open file: '%s'" % path, DebugHud.LogType.ERROR)
		return ""

	var contents:String = file.get_as_text()
	file.close()
	return contents
