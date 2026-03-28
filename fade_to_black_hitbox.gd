extends Node3D

func _on_area_3d_area_entered(area: Area3D) -> void:
	$CanvasLayer/FadeRect/AnimationPlayer.play("fade_to_black")
	$CanvasLayer/Label/AnimationPlayer.play("text_fade_in")
	#print("fade")
	pass # Replace with function body.
