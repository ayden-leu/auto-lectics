extends Node3D

@export var dialogueID:String = "Dialogue1a"
@export var npcName:String = "NPC_Test"

func _ready() -> void:
	var dialogue := Globals.getDialogueNode(npcName, dialogueID)
	
	print("--- DIALOGUE ---")
	print("text: ", dialogue.get("text"))
	print("type: ", dialogue.get("type"))
	print("font: ", dialogue.get("font"))
	print("writeSpeed: ", dialogue.get("writeSpeed"))
	print("writeSpeedCustom: ", dialogue.get("writeSpeedCustom"))
	print("sfx: ", dialogue.get("sfx"))
	print("bg theme: ", dialogue.get("backgroundTheme"))
	print("particles: ", dialogue.get("particles"))
	print("options: ", dialogue.get("options", []).size())
	print("")
	
	var counter:int = 0
	for option in dialogue.get("options", []):
		print("--- OPTION [", counter, "] ---")
		print(option)
		print("")
		
		counter += 1
