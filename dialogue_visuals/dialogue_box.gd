extends Node3D
class_name DialogueBox

signal update_me(next_id: String)

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
@onready var optionContainer = $OptionsContainer
@onready var warningTileScene:Resource = preload(Globals.SCENES.DialogueWarningTile)
@onready var warningAreas:Array = $WarningPositionAreas.get_children()
@onready var warningsContainer = $WarningsContainer

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var optionData:Array = []
var loadedOptions:Array = []
var mode:String = "normal"
var numWarnings:int = 6

func _ready() -> void:
	$WarningPositionAreas.visible = false
	
func _process(_delta: float) -> void:
	pass

func loadOptionData(options: Array) -> void:
	optionData = options
	optionData.sort_custom(func(a, b): return a.spawnDelay < b.spawnDelay)

func prepare() -> void:
	# TODO:  load configuration. maybe
	
	if mode == "hectic":
		spawnWarnings(numWarnings)

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
	optionContainer.add_child(option)
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

func spawnWarnings(amount:int) -> void:
	for _i in range(amount):
		var spawnLocation:Vector3 = getWarningTilePosition()
		
		var warningTile:WarningTile = warningTileScene.instantiate()
		warningsContainer.add_child(warningTile)
		warningTile.position = spawnLocation
		warningTile.look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)
		warningTile.connect("blocking_visual", _on_warning_tile_overlap)

func getWarningTilePosition() -> Vector3:
	# TODO:  round robin pick the areas instead
	# TODO:  reuse areas for positioning the options too
	rng.randomize()
	var chosenArea:MeshInstance3D = warningAreas[rng.randi_range(0,2)]
	
	var maxOffset:Vector3 = chosenArea.mesh.get_aabb().size
	var offset:Vector3 = Vector3(
		rng.randf_range(-maxOffset.x, maxOffset.x),
		rng.randf_range(-maxOffset.y, maxOffset.y),
		rng.randf_range(-maxOffset.z, maxOffset.z)
	)
	return chosenArea.position + offset

func kill() -> void:
	queue_free()



func _onOptionPicked(data) -> void:
	for _i in range(loadedOptions.size()):
		var toKill:DialogueOption = loadedOptions.pop_front()
		toKill.kill()
		
	emit_signal("update_me", data)

func _on_warning_tile_overlap(warningTile:WarningTile) -> void:
	# TODO:  move warning tile up and left/right instead of random position in area
	if warningTile.numTimesRepositioned > 3:
		return
	
	rng.randomize()
	var delay:float = rng.randf_range(0.0, 1.0)
	await get_tree().create_timer(delay).timeout
	warningTile.position = getWarningTilePosition()
	warningTile.numTimesRepositioned += 1
	warningTile.look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)
