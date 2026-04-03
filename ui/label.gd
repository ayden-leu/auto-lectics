
extends CanvasLayer
class_name StartingScreenForRealThisTime

@onready var flavorText = $Label
@onready var startText = $Label2

var isStartTextGoing = false

func _ready() -> void:
	flavorText.visible_ratio = 0
	startText.visible_characters = 0

func _updateFlavorText() -> void: 
	
	flavorText.visible_ratio += 0.001
	
	if flavorText.visible_ratio >= 1 :
		await get_tree().create_timer(1.0).timeout

		flavorText.visible = false
		startText.visible = true
		isStartTextGoing = true

func _updateStartText() -> void: 
	startText.visible_characters += 1

func _process(delta: float) -> void:
	_updateFlavorText()
	if isStartTextGoing == true:
		_updateStartText()

		 
		
	
