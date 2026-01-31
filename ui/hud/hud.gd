extends Control

# TODO:  actually code this because this is just quick and dirty

func _ready() -> void:
	var windowSize := DisplayServer.window_get_size()
	size = windowSize
	$Container.size = windowSize
