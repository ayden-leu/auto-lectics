@tool
extends InteractableNPC

var time : float
var base_position : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = rotation
	pass # Replace with fun ction body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	time += delta;
	#rotation = Vector3(base_position.x +get_sine(), 0, 0)
	#position = Vector3(base_position.x, base_position.y + get_sine(), base_position.z)
	#print(get_sine())
	pass

func get_sine():
	return sin(time * 0.5) * 1
