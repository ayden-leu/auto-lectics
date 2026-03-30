@tool
extends Label
class_name TypeWriterLabelStartingForRealThisTime
var visibleCharacters = 0.05


func _ready() -> void:
		visible = false

func _updateText() -> void: 
	
	visible_ratio =  visibleCharacters
	visibleCharacters += 0.001
	
	
func _process(delta: float) -> void:
		
	_updateText()
	
	
