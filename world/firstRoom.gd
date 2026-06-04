extends Node3D

func _ready() -> void:
	FR_MenuManager.enable() # either enable() or disable()
	FR_WindowManager.enable() # either enable() or disable()
	CursorHandler.setDefault("shown") # refer to documentation or hover over the function for valid values
	CursorHandler.hideNuclear() # either hideNuclear() or showNuclear()




# don't forget that _process() and _physics_process() exist.
# they'll show up on the auto-complete.

#
#func _on_loop_manager_resetting() -> void:
	##print("flicked")
	##print(get_tree().get_nodes_in_group("light"))
	#get_tree().call_group("light","_flicker")
	#pass # Replace with function body.

func _on_loop_manager_started_fancy() -> void:
	#print("flicked")
	get_tree().call_group("light","_flicker")
	pass # Replace with function body.


func _on_loop_manager_faded_in() -> void:
	get_tree().call_group("light","_stopFlicker")

	pass # Replace with function body.


func _on_change_respawn_body_entered(body: Node3D) -> void:
	print("updated marker")
	$Marker3D.global_position = Vector3(-23.0,25.0,23.0)



func _on_area_3d_body_entered(body: Node3D) -> void:
	get_tree().change_scene_to_file("res://world/1.5room.tscn")
	pass # Replace with function body.


func _on_vocal_dialogue_player_dialogue_finished() -> void:
	$dropPodStuff.visible = true
	pass # Replace with function body.


func _on_vocal_dialogue_player_dialogue_advanced() -> void:
	$dropPodStuff.visible = true
	pass # Replace with function body.
