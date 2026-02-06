extends Node3D

# TODO:  test the functions implemented in dialogue_db.gd

@export var dialogue_json_path := "res://dialogue_objects/NPC_Test/Dialogue1a.json"

func _ready() -> void:
	var loader := DialogueLoader.new()
	var dlg := loader.load_dialogue_node_file(dialogue_json_path)

	print("--- DIALOGUE ---")
	print("text:", dlg.get("text"))
	print("type:", dlg.get("type"))
	print("font:", dlg.get("font"))
	print("writeSpeed:", dlg.get("writeSpeed"), " custom:", dlg.get("writeSpeedCustom"))
	print("resolved cps:", loader.resolve_write_speed_chars_per_sec(dlg))
	print("sfx:", dlg.get("sfx"))
	print("bg theme:", dlg.get("backgroundTheme"))
	print("particles:", dlg.get("particles"))
	print("options:", dlg.get("options", []).size())

	if dlg.get("options", []).size() > 0:
		print("--- OPTION[0] ---")
		var o0: Dictionary = dlg["options"][0]
		print(o0)
		print("resolved cps:", loader.resolve_write_speed_chars_per_sec(o0))
