@tool
extends InteractableNPC

@onready var animation = $AnimatedSprite3D


func _process(_delta):
	if StoryFlags.currentFlags.hasExploded:
		animation.play("explosion")
		disable()
	
