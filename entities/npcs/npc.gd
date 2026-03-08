@icon("uid://4k8rw8ox10br")
@tool
extends Node3D
class_name NPC
## The base class of all NPCs in the game.  

## The main model of the NPC.  Not used for anything in the base NPC class, but may be used in classes or scripts that extend the NPC class.
@export var model:Node3D
## The name of the NPC.  Not used for anything in the base NPC class, but may be used in classes that extend the NPC class.
@export var myName:String = ""

func _ready() -> void:
	add_to_group("NPCs")



# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not model:
		warnings.push_back("This NPC doesn't have a model.")
	
	if myName == "":
		warnings.push_back("This NPC doesn't have a name yet.")
	
	return warnings
