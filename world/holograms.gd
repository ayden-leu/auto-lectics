extends Node3D


func _process(delta: float) -> void:
	if StoryFlags.currentFlags.hologramsOn: 
		visible = true
	else:
		visible = false
