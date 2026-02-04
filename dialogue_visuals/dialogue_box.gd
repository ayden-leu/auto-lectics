extends Node3D
class_name DialogueBox

signal update_me(next_id: String)

signal update_me

enum OPTIONS_ANCHOR {
	topLeft = 0,
	topRight = 1,
	bottomLeft = 2,
	bottomRight = 3
}

@export var optionsAnchor:OPTIONS_ANCHOR = OPTIONS_ANCHOR.topLeft

@onready var myLabel:Label3D = $DialogueLabel
var text:String = "":
	set(value):
		text = value
		myLabel.text = value
@onready var optionScene:Resource = preload(Globals.SCENES.DialogueOption)
@onready var optionSpawnPositions = {
	"normal": $OptionPositions/Normal.get_children()
}
@onready var optionConntainer = $OptionsContainer

var optionData:Array = []
var loadedOptions:Array = []
var mode:String = "normal"

func _ready() -> void:
	pass

func loadOptionData(options: Array) -> void:
	optionData = options
	optionData.sort_custom(func(a, b): return a.spawnDelay < b.spawnDelay)

func createOptions() -> void:
	var prevDelay:float = 0.0
	for optionObjectData in optionData:
		var spawnDelay = max(optionObjectData.spawnDelay - prevDelay, 0)
		if spawnDelay > 0:
			await get_tree().create_timer(optionObjectData.spawnDelay).timeout
		prevDelay += spawnDelay
		
		var newOption:DialogueOption = spawnOption()
		configureOptionInstance(newOption, optionObjectData)
		newOption.spawn()

func spawnOption() -> DialogueOption:
	var option:DialogueOption = optionScene.instantiate()
	optionConntainer.add_child(option)
	loadedOptions.push_back(option)
	return option

func setOptionPosition(option:DialogueOption) -> void:
	if loadedOptions.size() == 1:
		option.position = optionSpawnPositions.normal[optionsAnchor].position
		option.rotation_degrees = optionSpawnPositions.normal[optionsAnchor].rotation_degrees
		return
	
	var lastOption:DialogueOption = loadedOptions[-2]
	var offsetMultiplier:float = 1.001
	if optionsAnchor == OPTIONS_ANCHOR.bottomLeft or optionsAnchor == OPTIONS_ANCHOR.bottomRight:
		offsetMultiplier *= -1
	
	option.position = lastOption.position + Vector3(0, -lastOption.labelHeight * offsetMultiplier, 0)
	option.rotation_degrees = lastOption.rotation_degrees

func configureOptionInstance(instance:DialogueOption, data:Dictionary) -> void:
	setOptionPosition(instance)
	
	match optionsAnchor:
		OPTIONS_ANCHOR.topLeft:
			instance.horizontalAlignment = instance.HORIZONTAL_ALIGNMENT.right
			instance.verticalAlignment = instance.VERTICAL_ALIGNMENT.top
		OPTIONS_ANCHOR.topRight:
			instance.horizontalAlignment = instance.HORIZONTAL_ALIGNMENT.left
			instance.verticalAlignment = instance.VERTICAL_ALIGNMENT.top
		OPTIONS_ANCHOR.bottomLeft:
			instance.horizontalAlignment = instance.HORIZONTAL_ALIGNMENT.right
			instance.verticalAlignment = instance.VERTICAL_ALIGNMENT.bottom
		OPTIONS_ANCHOR.bottomRight:
			instance.horizontalAlignment = instance.HORIZONTAL_ALIGNMENT.left
			instance.verticalAlignment = instance.VERTICAL_ALIGNMENT.bottom
	
	# TODO:  apply this aspect properly
	# Optional: if your DialogueOption supports lifetime
	if option.has_method("set_lifetime") and data.has("lifetime"):
		option.set_lifetime(float(data.get("lifetime", -1.0)))
	elif "lifetime" in option:
		# If lifetime is a property, this will work too
		option.lifetime = float(data.get("lifetime", -1.0))
	
	#instance.name = data.text
	instance.text = data.text
	instance.nextDialogue = data.nextID
	instance.connect("option_picked", _onOptionPicked)
	
func kill() -> void:
	queue_free()

func _onOptionPicked(next_id: Variant) -> void:
	# Clear options
	while loadedOptions.size() > 0:
		var toKill: DialogueOption = loadedOptions.pop_front()
		toKill.kill()

	# Ensure we emit a string ID
	emit_signal("update_me", str(next_id))
