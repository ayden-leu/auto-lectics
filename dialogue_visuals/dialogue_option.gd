@tool
extends Node3D
class_name DialogueOption

signal option_picked

@onready var label:Label3D = $TextLabel
@onready var hitbox:CollisionShape3D = $Area3D/CollisionShape3D
@onready var background:Node3D = $Background

@export var dummyThickness:float = 0.08
@export var labelPadding:Vector2 = Vector2(0.1, 0.1)

var goingToDie:bool = false

var text:String = "":
	set(value):
		text = value
		label.text = value
var spawnDelay:float = 0.0
var nextDialogue:int = -1

func _ready() -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	visible = false
	
func _process(_delta: float) -> void:
	# Only runs this code while the game is running
	if Engine.is_editor_hint():
		applyLabelCustomization()

func spawn() -> void:
	
	await get_tree().create_timer(spawnDelay).timeout
	applyLabelCustomization()
	
	if goingToDie:
		return
	
	visible = true
	hitbox.disabled = false

func applyLabelCustomization() -> void:
	# TODO:  call after the configuration gets set up
	
	label.position.y = -labelPadding.y/2
	label.position.z = labelPadding.x/2
	
	var labelSize:Vector3 = label.get_aabb().size
	
	# setting the scale of a parent node because we cannot adjust the origin of a mesh
	background.scale = Vector3(
		dummyThickness,
		labelSize.y - label.position.y * 2,
		labelSize.x + label.position.z * 2
	)
	
	# can't scale an area 3d without issues, so we gotta do the other route
	hitbox.shape.size = background.scale + Vector3.ONE * 0.05
	hitbox.position = Vector3(
		0,
		-background.scale.y/2,
		background.scale.z/2
	)

func kill():
	goingToDie = true
	queue_free()

func _onInteraction() -> void:
	emit_signal("option_picked", nextDialogue)
