extends Area3D
class_name StartDialogueAreaTemp
## A quickly-made sub-class of [Area3D] for the purpose of starting dialogues
## when a [Player] enters an area.
##
## When a [Player] enters this node's [CollisionShape3D], it makes
## an [InteractableNPC] start its dialogue as if the [Player] interacted with
## it directly.
## [br][br]
## Doesn't come with a [CollisionShape3D] by default, so be sure to add one yourself.

## The [InteractableNPC] that will start its dialogue when a [Player] enters the area.
@export var interactableNpcToInitiate:InteractableNPC

func _on_area_entered(area: Area3D) -> void:
	var areaOwner:Node3D = area.get_parent()
	if areaOwner is Player:
		interactableNpcToInitiate._on_interaction(areaOwner)
