extends Area3D
class_name DeathPlane
## Death plane is currently set as a world boundary. Can be changed to a box if design calls for it.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

## Causes player to respawn at last grounded location if they touch the death plane.
func _on_body_entered(body: Node) -> void:
	if body.has_method("respawn"):
		body.respawn()
	else:
		push_warning("DeathPlane: Body missing respawn()")
