extends Node

@export var amIOnTheTitleScreen = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("start_game"):
		amIOnTheTitleScreen = false
		$CanvasLayer/Label2.visible = false
		$CanvasLayer/ColorRect.visible = false
		get_tree().change_scene_to_file("res://world/week_10_playtest.tscn")
							
	elif event.is_action_pressed("close_game_from_title_screen"):
		if amIOnTheTitleScreen == true and $CanvasLayer/Label2.visible == true: 
			get_tree().quit()
		
	

			
