@tool
extends InteractableNPC

@onready var animation = $AnimatedSprite3D


func _process(_delta):
	# the below code snippet makes it so this doesn't spam the editor console
	# with a bunch of error messages.
	# if this node is being loaded while in the editor view,
	if Engine.is_editor_hint():
		# do nothing
		return
	
	# this runs the inherited class' _process() function, which doesn't
	# happen automatically.
	super(_delta) 
	
	if StoryFlags.currentFlags.hasExploded:
		animation.play("explosion")
		
		disable()
		await get_tree().create_timer(1.0).timeout
		visible = false
