@tool
extends InteractableNPC

var time : float
var base_position : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	base_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super(delta)
	
	time += delta;
	position = Vector3(base_position.x  + get_sine(), base_position.y, base_position.z)
	#print(get_sine())
	pass

func get_sine():
	return sin(time * 2) * 0.05

# ----------------------------

# NOTE 1
# since InteractableNPCs already "subscribe" themselves to the DialogueConsole
# when you interact with them, we don't have to add extra code to
# "subscribe" to it, nor add an extra check to make sure this InteractableNPC
# isTalking.
#
# NOTE 2
# miniboss and the lookerNPC share the same script.  this means that entering
# the `open_gate` command while talking to the lookerNPC will run the function.
# However, it won't open the gate due to the check I added to see if
# the $gateNode exists beforehand.
# 
# NOTE 3
# if you want to make it so the `open_gate` command opens the gate regardless
# of who opens the console, comment the below code out, and refer to
# the script attached to the root node of the `spring_week_3_playtest.tscn` scene.
func _on_console_command_entered(command:String) -> void:
	if command == "open_gate":
		if $gateNode:
			$gateNode.open_gate()
