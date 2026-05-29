extends Node3D


var imSpinning = 0 



func _process(delta: float) -> void:
	imSpinning += -0.00003
	rotation.y = imSpinning
