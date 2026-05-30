extends Node
class_name DialogueDefaults
## Holds default definitions for all dialogue-related aspects.
##
## This class stores the valid dialogue values and fallback dictionaries used by
## [DialogueLoader] when loading dialogue JSON files.
## [br][br]
## [b]Use Case[/b][br]
## Use this class when adding, validating, or changing dialogue configuration
## values. For example, new dialogue types, option types, write speed presets,
## or default JSON fields should be added here.
## [br][br]
## [b]How to Use[/b][br]
## Designers do not usually interact with this class directly. Instead, they
## create dialogue JSON files. [DialogueLoader] then uses the dictionaries in
## this class to fill in any missing values.
## [br][br]
## [b]Important Notes[/b][br]
## Fields in [member DEFAULT_DIALOGUE] and [member DEFAULT_OPTION] should match
## the expected keys in the dialogue JSON files. If a JSON file omits a field,
## the corresponding value here is used as the fallback.

## The types of dialogue that exist.
## [br][br]
## Dialogue JSON files should use one of these strings for their
## [code]type[/code] field. Invalid values are replaced by the default type.
## [br][br]
const DIALOGUE_TYPES:Array[String] = [
	"neutral", "happy", "angry", "confused", "sad"
]

## The modes a dialogue object can be in, in string form.
## [br][br]
## [code]normal[/code] dialogue displays normally. [code]hectic[/code] dialogue
## uses additional hectic behaviour.
## [br][br]
const DIALOGUE_MODES:Array[String] = [
	"normal", "hectic"
]

## The types of options that exist.
## [br][br]
## Dialogue option JSON objects should use one of these strings for their
## [code]type[/code] field. Invalid values are replaced by the default type.
## [br][br]
const OPTION_TYPES:Array[String] = [
	"neutral", "positive", "negative"
]

## Text write speed presets.
## [br][br]
## These values represent characters per second. A larger number means the text
## appears faster.
## [br][br]
## [code]inherit[/code] is used by options to copy the dialogue object's write
## speed. [code]custom[/code] allows [code]writeSpeedCustom[/code] to be used
## instead of a preset.
## [br][br]
const WRITE_SPEED_PRESETS:Dictionary = {
	"inherit": -1.0,
	"slow": 30.0,
	"medium": 60.0,
	"fast": 120.0,
	"custom": -1.0
}

## Events where a SFX can play.
## [br][br]
## [code]spawn[/code] plays when a dialogue object or option appears.
## [code]text[/code] plays while text is being written.
## [br][br]
const SFX_EVENTS:Array[String] = [
	"spawn", "text"
]

## The default settings for a dialogue object.
## [br][br]
## These values are copied by [DialogueLoader] when loading a dialogue node.
## Any matching fields in the JSON file override these defaults.
## [br][br]
## [b]Mandatory Fields[/b][br]
## [code]text[/code] is the dialogue text displayed to the player.
## [code]options[/code] is the list of option objects the player can choose from.
## If the list is empty, the dialogue will end or continue based on the loading
## logic.
## [br][br]
## [b]Optional Fields[/b][br]
## Optional fields control presentation, mode-specific behaviour, writing speed,
## and SFX. If omitted from the JSON file, these values are used.
## [br][br]
const DEFAULT_DIALOGUE:Dictionary = {
	# === Mandatory ===
	"text": "",
	"options": [],

	# === Optional ===
	"type": "neutral",  # see DIALOGUE_TYPES
	"mode": "normal",
	"nextOnHecticFailureID": "",
	"hecticDuration": 25.0,
	"textThemePreset": "_defaultConsoleBot",
	"writeSpeed": "medium",
	"writeSpeedCustom": 0.0,

	"sfx": {
		"spawn": "none",
		"text": "none"
	}
}

## The default settings for a dialogue option.
## [br][br]
## These values are copied by [DialogueLoader] when loading an option object.
## Any matching fields in the JSON file override these defaults.
## [br][br]
## [b]Mandatory Fields[/b][br]
## [code]text[/code] is the text shown for this option.
## [code]nextID[/code] is the dialogue ID to load when this option is chosen.
## If [code]nextID[/code] is an empty string, the dialogue ends.
## [br][br]
## [b]Story Flags[/b][br]
## [code]checkFlags[/code] controls whether this option is shown.
## [code]setFlags[/code] controls which flags are updated when this option is
## chosen.
## [br][br]
## [b]Backtracking[/b][br]
## If [code]allowBack[/code] is false, choosing this option prevents the player
## from returning to the parent dialogue node with the console's back command.
## [code]rejectBackMessage[/code] is displayed if the player tries to go back to one
## of these dialogue nodes.
## [br][br]
const DEFAULT_OPTION:Dictionary = {
	# === Mandatory ===
	"text": "",
	"nextID": "",

	# === Optional ===
	"type": "neutral",  # see OPTION_TYPES
	"textThemePreset": "_defaultConsolePlayer",
	"writeSpeed": "inherit",
	"writeSpeedCustom": -1.0,

	"checkFlags": {},
	"setFlags": {},

	"allowBack": true,
	"rejectBackMessage": "[ERROR: Cannot go back to previous dialogue ID]",

	"sfx": {
		"spawn": "none",
		"text": "none"
	},

	"spawnDelay": 0.0,
	"lifetime": 0.0,
}
