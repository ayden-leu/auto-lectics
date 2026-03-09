extends Node
class_name DialogueDefaults

## The types of dialogue that exist.
const DIALOGUE_TYPES:Array[String] = [
	"neutral", "happy", "angry", "confused", "sad"
]
## The modes a dialogue object can be in.
const DIALOGUE_MODES:Array[String] = [
	"normal", "hectic"
]
## The types of options that exist.
const OPTION_TYPES:Array[String] = [
	"positive", "neutral", "negative"
]
## Text write speed presets.
const WRITE_SPEED_PRESETS:Dictionary = {
	"slow": 30.0,
	"medium": 60.0,
	"fast": 120.0,
	"custom": -1.0
}
## Background theme presets.
const BACKGROUND_THEME:Dictionary = {
	# TODO:  add background theme presets.
	"default": "todo"
}
## Events where a particle can spawn.
const PARTICLE_EVENTS:Array[String] = [
	"spawn", "text", "ambient"
]
## Attributes a particle event has.
const PARTICLE_EVENT_ATTRIBUTES:Array[String] = [
	"texture"
]
## Paths to particle textures.
const PARTICLE_TEXTURE:Dictionary = {
	# TODO:  add particle textures
}
## Events where a SFX can play.
const SFX_EVENTS:Array[String] = [
	"spawn", "text"
]

## Returns a default dialogue object.
static func default_dialogue() -> Dictionary:
	return {
		# === Mandatory ===
		"text": "",
		"options": [],

		# === Optional ===
		"mode": "normal",
		"nextOnHecticFailureID": "",
		"font": "default",
		"type": "neutral",
		"writeSpeed": "medium",
		"writeSpeedCustom": -1.0,

		"sfx": {
			"spawn": "none",
			"text": "default"
		},

		"backgroundTheme": "default",

		"particles": {
			"spawn": { "texture": "none" },
			"text": { "texture": "none" },
			"ambient": { "texture": "none" }
		}
	}

## Returns a default option object.
static func default_option() -> Dictionary:
	return {
		# === Mandatory ===
		"text": "",
		"nextID": "",

		# === Optional ===
		"font": "inherit",
		"type": "neutral",
		"checkFlag": [],
		"setFlag": [],
		"writeSpeed": "inherit",
		"writeSpeedCustom": -1.0,

		"sfx": {
			"spawn": "inherit",
			"text": "inherit"
		},

		"backgroundTheme": "inherit",

		"particles": {
			"spawn": { "texture": "inherit" },
			"text": { "texture": "inherit" },
			"ambient": { "texture": "inherit" }
		},

		"spawnDelay": 0.0,
		"lifetime": -1.0,
	}
