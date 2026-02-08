extends Node 

# Put any game-wide variables and information here
# Everything in here can be accessed via `Globals.[thing]`
#	Example:  Globals.SCENES.Player

## Holds path references to any scene that needs to be spawned via code. Should be in the format "uid://[string of characters]" so things don't break when files are moved around. You can get this string by dragging the scene file into the script editor, then holding Ctrl+Alt before dropping it. Be sure to remove the "preload" part.
const SCENES = {
	"Player": "uid://co1nc22ck82l0",
	"NPC_test": "uid://bq04u0nihuu52",
	"DialogueBox": "uid://dwqide2q2tp3i",
	"DialogueOption": "uid://pdwngeenin11",
	"DialogueWarningTile": "uid://wm6t0orfpjfl"
}

## Holds information for where the dialogue object files are stored and their file type.
const DIALOGUE = {
	"storageLocation": "res://dialogue_objects/",
	"fileType": ".json"
}

## Gets the path to a dialogue object.
func getDialoguePath(entityName:String, id:String) -> String:
	return DIALOGUE.storageLocation + entityName + "/" + id + DIALOGUE.fileType

## Gets the dialogue information within a dialogue object.
func getDialogueNode(entityName:String, id: String) -> Dictionary:
	var path:String = getDialoguePath(entityName, id)
	var dialogue:Dictionary = DialogueLoader.loadDialogueNodeFile(path)
	
	if dialogue.is_empty():
		printerr("NPC: Failed to load dialogue id '%s' at '%s'" % [id, path])
		return DialogueLoader.loadDialogueNodeFile(
			DIALOGUE.storageLocation + "fallback" + DIALOGUE.fileType
		)
	return dialogue

## Unused. enum mapping for collision layers.
enum COLLISION_LAYER {
	player = 1,
	environment = 2,
	npc = 3,
	visuals = 4
}
