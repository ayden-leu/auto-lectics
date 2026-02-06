extends Node3D

# TODO:  test the functions implemented in dialogue_db.gd

@export var dialogueID:String = "Dialogue1a"
var dialogueStorageLocation:String = "res://dialogue_objects/NPC_Test/"
var dialogueFileType:String = ".json"

func _ready() -> void:
	var loader := DialogueLoader.new()
	var dialogue := loader.load_dialogue_node_file(
		dialogueStorageLocation + dialogueID + dialogueFileType
	)

	print("--- DIALOGUE ---")
	print("text: ", dialogue.get("text"))
	print("type: ", dialogue.get("type"))
	print("font: ", dialogue.get("font"))
	print("writeSpeed: ", dialogue.get("writeSpeed"))
	print("writeSpeedCustom: ", dialogue.get("writeSpeedCustom"))
	print("resolved cps: ", loader.resolve_write_speed_chars_per_sec(dialogue))
	print("sfx: ", dialogue.get("sfx"))
	print("bg theme: ", dialogue.get("backgroundTheme"))
	print("particles: ", dialogue.get("particles"))
	print("options: ", dialogue.get("options", []).size())
	print("")
	
	var counter:int = 0
	for option in dialogue.get("options", []):
		print("--- OPTION [", counter, "] ---")
		print(option)
		print("resolved cps:", loader.resolve_write_speed_chars_per_sec(option))
		print("")
		
		counter += 1
