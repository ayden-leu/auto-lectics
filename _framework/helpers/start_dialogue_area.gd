@tool
@icon("uid://cgvywsq714hf3")
extends Area3D
class_name StartDialogueArea
## An [Area3D] that automatically starts dialogue when the [class Player] enters it. 
## 
## Use this when a dialogue should begin from entering a trigger area 
## instead of requiring the player to manually interact with an NPC. 
## [br][br] 
## To use, add this node to a scene and add a [class CollisionShape3D] 
## as its child. Then assign the desired [class InteractableNPC] to 
## [member interactableNpcToInitiate]. 
## [br][br] 
## When the [class Player] enters this area's [class CollisionShape3D], 
## this node tells the assigned [class InteractableNPC] to start its 
## dialogue as if the player had interacted with it directly. 
## [br][br] 
## Doesn't come with a [class CollisionShape3D] by default. 
## One must be added and configured for the trigger area to work.

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The [InteractableNPC] that will start its dialogue when a [Player] enters the area.
@export var interactableNpcToInitiate:InteractableNPC

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when the area is entered by another area.
func _on_area_entered(area:Area3D) -> void:
	var areaOwner:Node3D = area.get_parent()
	if areaOwner is Player:
		interactableNpcToInitiate._on_interaction(areaOwner)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------

func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if not interactableNpcToInitiate:
		warnings.push_back(
			"An InteractableNPC is not set."
		)

	return warnings
