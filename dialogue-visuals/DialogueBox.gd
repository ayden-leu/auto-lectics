extends Node3D
class_name DialogueBox

@onready var myLabel:Label3D = $DialogueLabel
#var optionScenePath:String = "res://dialogue-visuals/dialogue-option.tscn"

var delayStartShowingOptions:float = 1.0
var delayBetweenOptions:float = 0.5

var optionData:Array = []
@onready var optionSpawnPositions = $OptionPositions.get_children()

func _ready() -> void:
	visible = false
	
func _process(_delta: float) -> void:
	pass


func initialize() -> void:
	visible = true
	
	await get_tree().create_timer(delayStartShowingOptions).timeout
	
	for option in optionData:
		#spawnOption()
		pass

func setDialogueText(text:String) -> void:
	myLabel.text = text

func loadOptionData(options:Array) -> void:
	optionData = options

func spawnOption(optionData:Dictionary, position:Vector3) -> void:
	pass
