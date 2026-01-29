extends Node3D
class_name DialogueBox

signal update_me

@onready var myLabel:Label3D = $DialogueLabel
var text:String = "":
	set(value):
		text = value
		myLabel.text = value

@onready var optionScene:Resource = preload("res://dialogue-visuals/DialogueOption.tscn")
@onready var optionSpawnPositions = $OptionPositions.get_children()
var optionData:Array = []
var loadedOptions:Array = []

func _ready() -> void:
	#visible = false
	pass
	
func _process(_delta: float) -> void:
	pass

func loadOptionData(options:Array) -> void:
	optionData = options

func createOptions() -> void:
	for i in range(optionData.size()):
		spawnOption(optionData[i], optionSpawnPositions[i])

func spawnOption(data:Dictionary, marker:Marker3D) -> void:
	var option:DialogueOption = optionScene.instantiate()
	marker.add_child(option)
	loadedOptions.push_back(option)
	
	option.text = data.text
	option.nextDialogue = data.nextID
	option.spawnDelay = data.spawnDelay
	option.connect("option_picked", _onOptionPicked)
	option.spawn()
	
func _onOptionPicked(data) -> void:
	for _i in range(loadedOptions.size()):
		var toKill:DialogueOption = loadedOptions.pop_front()
		toKill.kill()
		
	emit_signal("update_me", data)

func dummyFunction(index:int) -> void:
	loadedOptions[index-1].picked()

func kill() -> void:
	queue_free()
