extends Node
class_name DialogueDefaults
### Holds default definitions for all dialogue-related aspects.

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
## @deprecated
## Background theme presets.
const BACKGROUND_THEME:Dictionary = {
	# TODO:  add background theme presets.
	"default": "todo"
}
## @deprecated
## Events where a particle can spawn.
const PARTICLE_EVENTS:Array[String] = [
	"spawn", "text", "ambient"
]
## @deprecated
## Attributes a particle event has.
const PARTICLE_EVENT_ATTRIBUTES:Array[String] = [
	"texture"
]
## @deprecated
## Paths to particle textures.
const PARTICLE_TEXTURE:Dictionary = {
	# TODO:  add particle textures
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
	"mode": "normal",
	"nextOnHecticFailureID": "",
	"font": "default",
	"type": "neutral",
	"writeSpeed": "medium",
	"writeSpeedCustom": 0.0,

	"sfx": {
		"spawn": "none",
		"text": "none"
	},

	"backgroundTheme": "default",

	"particles": {
		"spawn": { "texture": "none" },
		"text": { "texture": "none" },
		"ambient": { "texture": "none" }
	}
}

## The default settings for a dialogue option.
const DEFAULT_OPTION:Dictionary = {
	# === Mandatory ===
	"text": "",
	"nextID": "",

	# === Optional ===
	"font": "inherit",
	"type": "neutral",
	"writeSpeed": "inherit",
	"writeSpeedCustom": -1.0,

	"checkFlags": {},
	"setFlags": {},

	"sfx": {
		"spawn": "none",
		"text": "none"
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
