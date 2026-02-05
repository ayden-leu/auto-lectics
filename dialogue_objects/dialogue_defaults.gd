extends Node
class_name DialogueDefaults

const DIALOGUE_TYPES := ["neutral", "happy", "angry", "confused", "sad"]
const OPTION_TYPES := ["positive", "neutral", "negative"]

# Preset -> speed mapping
const WRITE_SPEED_PRESETS := {
	"slow": 30.0,
	"medium": 60.0,
	"fast": 120.0
}

static func default_dialogue() -> Dictionary:
	return {
		"text": "",
		"font": "default",
		"type": "neutral",
		"mode": "normal",

		# Typewriter
		"writeSpeed": "medium",
		"writeSpeedCustom": -1.0,

		# SFX
		"sfx": {
			"spawn": "none",
			"text": "default"
		},

		# Background theme preset
		"backgroundTheme": "default",

		# Particles
		"particles": {
			"spawn": { "texture": "none" },
			"text": { "texture": "none" },
			"ambient": { "texture": "none" }
		},

		# Options list
		"options": []
	}

static func default_option() -> Dictionary:
	return {
		"text": "",
		"font": "inherit",
		"type": "neutral",

		# Typewriter (options inherit by default)
		"writeSpeed": "inherit",
		"writeSpeedCustom": -1.0,

		# SFX (options inherit by default)
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
		"nextID": ""
	}
