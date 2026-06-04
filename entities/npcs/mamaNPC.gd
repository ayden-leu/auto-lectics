@tool
extends InteractableNPC

var time : float
var base_position : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	base_position = model.rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super(delta)
	

	#time += delta;
	#model.rotation = Vector3(0, base_position.y +get_sine(), 0)
	#position = Vector3(base_position.x, base_position.y + get_sine(), base_position.z)
	#print(get_sine())
	pass

func get_sine():
	return sin(time * 0.5) * 1
