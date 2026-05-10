@tool
@icon("uid://cgvywsq714hf3")
extends Area3D
class_name StartDialogueArea
## An [Area3D] that triggers a dialogue event between a [Player] and [InteractableNPC].
##
## When a [Player] enters this node's [CollisionShape3D], it makes
## an [InteractableNPC] start its dialogue as if the [Player] interacted with
## it directly.
## [br][br]
## Doesn't come with a [CollisionShape3D] by default.

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
