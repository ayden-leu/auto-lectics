extends Node3D
class_name DialogueOption

signal option_picked

@onready var label:Label3D = $TextLabel

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
	visible = true

func picked() -> void:
	emit_signal("option_picked", nextDialogue)

func _onInteraction() -> void:
	picked()

func kill():
	queue_free()
