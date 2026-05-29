extends Node3D


var imSpinning = 0 



func _process(delta: float) -> void:
	imSpinning += 0.0001
	rotation.y = imSpinning
