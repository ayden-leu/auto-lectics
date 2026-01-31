extends Node3D

@onready var testNPC:NPC = $NPC_Test

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

var counter:int = 0
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_1"):
		match counter:
			0:
				testNPC._onInteraction()
			1:
				testNPC.dialogueBox.loadedOptions[0].picked()
		
		counter += 1
	
