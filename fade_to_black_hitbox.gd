extends Node3D

@export var shouldIReloadTheScene = false

func _on_area_3d_area_exited(area: Area3D) -> void:
	$CanvasLayer/FadeRect/AnimationPlayer.play("fade_to_black")
	$CanvasLayer/Label/AnimationPlayer.play("text_fade_in")
	$Timer.start()
	 # Access via scene main loop.
	
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	shouldIReloadTheScene = true
	pass # Replace with function body.
