extends Node3D

#@export var shouldIReloadTheScene = false

@onready var overlay: FadeToBlackOverlay = %FadeToBlackOverlay

func _on_area_3d_area_exited(area: Area3D) -> void:
	print("fadetoblackStarted")
	overlay.startFadeIn()
	await overlay.fade_in_complete
	
	$CanvasLayer/CreditsLabel/AnimationPlayer.play("text_fade_in")
	$Timer.start()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://entities/player/starting_screen_handler.tscn")

func _on_inactivity_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://entities/player/starting_screen_handler.tscn")

func _input(event: InputEvent) -> void:
	if event: 
		$"Inactivity Timer".start(180)
		#print("restarting game due to inactivity")
		
