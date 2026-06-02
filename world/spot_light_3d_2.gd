extends SpotLight3D

func _process(delta: float) -> void:
	if StoryFlags.currentFlags.dropPod:_turnOn()
		

func _turnOn():
	light_energy = 14.814
