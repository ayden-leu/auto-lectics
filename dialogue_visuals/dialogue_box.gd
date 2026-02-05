extends Node3D
class_name DialogueBox

signal update_me(next_id: String)

@onready var myLabel: Label3D = $DialogueLabel
var text: String = "":
	set(value):
		text = value
		myLabel.text = value

@onready var optionScene: Resource = preload(Globals.SCENES.DialogueOption)
@onready var optionSpawnPositions: Array = $OptionPositions.get_children()

var optionData: Array = []          # Array[Dictionary]
var loadedOptions: Array = []       # Array[DialogueOption]

func _ready() -> void:
	pass

func loadOptionData(options: Array) -> void:
	optionData = options

func createOptions() -> void:
	# Safety: don’t spawn more options than we have markers for
	var count = min(optionData.size(), optionSpawnPositions.size())
	for i in range(count):
		spawnOption(optionData[i], optionSpawnPositions[i])

func spawnOption(data: Dictionary, marker: Marker3D) -> void:
	var option: DialogueOption = optionScene.instantiate()
	marker.add_child(option)
	loadedOptions.append(option)

	# IMPORTANT: dictionary access via []
	option.text = str(data.get("text", ""))

	# nextID is what NPC expects to load next json; empty string ends
	option.nextDialogue = str(data.get("nextID", ""))

	# Spawn delay default 0 if missing
	option.spawnDelay = float(data.get("spawnDelay", 0.0))

	# Optional: if your DialogueOption supports lifetime
	if option.has_method("set_lifetime") and data.has("lifetime"):
		option.set_lifetime(float(data.get("lifetime", -1.0)))
	elif "lifetime" in option:
		# If lifetime is a property, this will work too
		option.lifetime = float(data.get("lifetime", -1.0))

	option.connect("option_picked", Callable(self, "_onOptionPicked"))
	option.spawn()

func kill() -> void:
	queue_free()

func _onOptionPicked(next_id: Variant) -> void:
	# Clear options
	while loadedOptions.size() > 0:
		var toKill: DialogueOption = loadedOptions.pop_front()
		toKill.kill()

	# Ensure we emit a string ID
	emit_signal("update_me", str(next_id))
