extends Node
class_name DialogueDefaults
### Holds default definitions for all dialogue-related aspects.

## The types of dialogue that exist.
const DIALOGUE_TYPES:Array[String] = [
	"neutral", "happy", "angry", "confused", "sad"
]
## The modes a dialogue object can be in, in string form.
const DIALOGUE_MODES:Array[String] = [
	"normal", "hectic"
]
## The types of options that exist.
const OPTION_TYPES:Array[String] = [
	"neutral", "positive", "negative"
]
## Text write speed presets.
const WRITE_SPEED_PRESETS:Dictionary = {
	"inherit": -1.0,
	"slow": 30.0,
	"medium": 60.0,
	"fast": 120.0,
	"custom": -1.0
}
## Events where a SFX can play.
const SFX_EVENTS:Array[String] = [
	"spawn", "text"
]

## The default settings for a dialogue object.
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
