extends Node 

# Put any game-wide variables and information here
# Everything in here can be accessed via `Globals.[thing]`
#	Example:  Globals.SCENES.Player

const SCENES = {
	"Player": "uid://co1nc22ck82l0",
	"NPC_test": "uid://bq04u0nihuu52",
	"DialogueBox": "uid://dwqide2q2tp3i",
	"DialogueOption": "uid://pdwngeenin11"
}

const DIALOGUE = {
	"storageLocation": "res://dialogue_objects/",
	"fileType": ".json"
}
var dialogueLoader:DialogueLoader = DialogueLoader.new():
	set(value):
		return

func getDialoguePath(entityName:String, id:String) -> String:
	return DIALOGUE.storageLocation + entityName + "/" + id + DIALOGUE.fileType

func loadDialogueNode(entityName:String, id: String) -> Dictionary:
	var path:String = getDialoguePath(entityName, id)
	var dialogue := dialogueLoader.load_dialogue_node_file(path)
	if dialogue.is_empty():
		push_warning("NPC: Failed to load dialogue id '%s' at '%s'" % [id, path])
	return dialogue
