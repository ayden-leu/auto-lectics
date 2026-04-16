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
	"DialogueWarningTile3D": "uid://wm6t0orfpjfl",
	"DialogueConsoleWindow": "uid://b8oqtsvu488a",
	"DialogueConsoleOptionWindow": "uid://4opwac4ndc2k"
}

## Holds information for where certain aspects are stored in the project.
const STORAGE_PATH = {
	"DIALOGUE": "res://dialogue_objects/",
	"SFX": "res://sounds/sfx/"
}
## Determines the file type of the dialogue objects.
const DIALOGUE_FILE_TYPE = ".json"

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
## Gets the path to a dialogue object.
func getDialoguePath(entityName:String, id:String) -> String:
	return STORAGE_PATH.DIALOGUE + entityName + "/" + id + DIALOGUE_FILE_TYPE

## Gets the dialogue information within a dialogue object.
func getDialogueNode(entityName:String, id: String) -> Dictionary:
	var path:String = getDialoguePath(entityName, id)
	var dialogue:Dictionary = DialogueLoader.loadDialogueNodeFile(path)
	
	if dialogue.is_empty():
		printerr("NPC: Failed to load dialogue id '%s' at '%s'" % [id, path])
		return DialogueLoader.loadDialogueNodeFile(
			STORAGE_PATH.DIALOGUE + "fallback" + DIALOGUE_FILE_TYPE
		)
	return dialogue

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
