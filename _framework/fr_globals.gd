extends Node

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------
## @deprecated
## Unused. enum mapping for collision layers.
enum COLLISION_LAYER {
	player = 1,
	environment = 2,
	npc = 3,
	visuals = 4
}

# ------------------------------------------------
# constants
# ------------------------------------------------
## Holds path references to any scene that needs to be spawned via code. Should be in the format "uid://[string of characters]" so things don't break when files are moved around.
## [br][br]
## You can get this UID string by right-clicking the scene in the FileSystem
## and clicking "Copy UID."  You can also drag the scene file into the script editor,
## then holding Ctrl+Alt before dropping it. Be sure to remove the "preload" part.
const SCENES = {
	"Player": "uid://co1nc22ck82l0",
	"DialogueBox": "uid://dwqide2q2tp3i",
	"DialogueBoxOption": "uid://pdwngeenin11",
	"WarningTile3D": "uid://wm6t0orfpjfl",
	"DialogueConsoleWindow": "uid://b8oqtsvu488a",
	"DialogueConsoleOptionWindow": "uid://4opwac4ndc2k",
	"DialogueConsoleLogEntry": "uid://1n8yvdu14dcd",
	"DialogueConsoleLogEntrySpacer": "uid://2pbfftop6j5e",
	"DialogueConsoleLogEntryIdLabel": "uid://cdt7ouilmdwo0",
	"DialogueWarningTileWindow": "uid://dpeqr6fpd34gm",
	"WarningTile2D": "uid://c1qmg4lyrgjqc",
	"BlueprintWindow": "uid://ovwd5xcohsao",
	"BlueprintNpcDetailWindow": "uid://524kk63lga7"
}

## Holds information for where certain aspects are stored in the project.
const STORAGE_PATH = {
	"DIALOGUE": "res://dialogue_trees/",
	"SFX": "res://sounds/sfx/",
	"LABEL_PRESETS": "res://fonts/_label_presets/"
}

## Determines the file type of label presets.
const LABEL_PRESET_FILE_TYPE = ".tres"
## The z index of [Menu]s.
const MENU_Z_INDEX:int = 10

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

## Gets the dialogue information within a dialogue object.
func getDialogueNode(entityName:String, id: String) -> Dictionary:
	var topPath:String = DialogueLoader.assemblePath(entityName, id)
	var top:Dictionary = DialogueLoader.loadDialogueNodeFile(topPath)
	if top.is_empty():
		printerr("NPC: Failed to load dialogue id '%s' at '%s'" % [id, topPath])
		top = DialogueLoader.loadDialogueNodeFile(
			STORAGE_PATH.DIALOGUE + "fallback" + DialogueLoader.DIALOGUE_FILE_TYPE
		)

	var npcDialogueDefaultsPath:String = DialogueLoader.assemblePath(entityName, DialogueLoader.DEFAULT_DIALOGUE_ID)
	var npcDialogueDefaults:Dictionary = DialogueLoader.loadDialogueNodeFile(npcDialogueDefaultsPath, false)
	if npcDialogueDefaults.is_empty():
		print("NPC: No default dialogue attribute file found for NPC '%s' at '%s'" % [entityName, topPath])

	var npcOptionDefaultsPath:String = DialogueLoader.assemblePath(entityName, DialogueLoader.DEFAULT_OPTION_ID)
	var npcOptionDefaults:Dictionary = DialogueLoader.loadDialogueNodeFile(npcOptionDefaultsPath, false)
	if npcOptionDefaults.is_empty():
		print("NPC: No default option attribute file found for NPC '%s' at '%s'" % [entityName, topPath])

	var withNpcDefaults:Dictionary = DialogueLoader.fillNpcDialogueDefaults(top, npcDialogueDefaults, npcOptionDefaults)

	var result:Dictionary = DialogueLoader.fillDialogueMissingFields(withNpcDefaults)

	return result

## Gets the current size of the screen.
func getScreenSize() -> Vector2:
	return get_viewport().get_visible_rect().size
	#return DisplayServer.screen_get_size()
	#return get_window().size

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
