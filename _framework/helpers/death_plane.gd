extends Area3D
class_name DeathPlane
## Runs a colliding body's [code]respawn()[/code] function upon collision.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

## [b]Internal-use only.[/b]  Does the thing this class is meant to do upon collision.
func _on_body_entered(body: Node) -> void:
	if body.has_method("respawn"):
		## plays anmiation
		$CanvasLayer/FadeRect/AnimationPlayer.play("cut_to_black")
		$death.play()
		## waits a second before respawning
		await get_tree().create_timer(2.0).timeout
		
		body.respawn()
		$respawn.play()
	else:
		push_warning("DeathPlane: Body missing respawn()")
	
