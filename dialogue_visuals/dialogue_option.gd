extends Node3D
class_name DialogueOption

signal option_picked

@onready var label:Label3D = $TextLabel
@onready var hitbox:CollisionShape3D = $Area3D/CollisionShape3D

var goingToDie:bool = false

var text:String = "":
	set(value):
		text = value
		label.text = value
var spawnDelay:float = 0.0
var nextDialogue:int = -1

func _ready() -> void:
	visible = false
	
func _process(_delta: float) -> void:
	pass

func spawn() -> void:
	await get_tree().create_timer(spawnDelay).timeout
	
	if goingToDie:
		return
	
	visible = true
	hitbox.disabled = false

func picked() -> void:
	emit_signal("option_picked", nextDialogue)

func _onInteraction() -> void:
	picked()

func kill():
	goingToDie = true
	queue_free()
