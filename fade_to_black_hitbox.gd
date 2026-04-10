extends Node3D

#@export var shouldIReloadTheScene = false

func _on_area_3d_area_exited(area: Area3D) -> void:
	print("fadetoblackStarted")
	$CanvasLayer/FadeRect/AnimationPlayer.play("fade_to_black")
	#$CanvasLayer/Label2.visible
	await get_tree().create_timer(1.0).timeout

	$CanvasLayer/Label2/AnimationPlayer.play("text_fade_in")
	$Timer.start()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://entities/player/starting_screen_handler.tscn")
 
