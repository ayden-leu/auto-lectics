extends Node3D
class_name DialogueBox

# TODO:  adjust size of dialogue box dynamically

signal update_me(next_id: String)

signal new_option_available
signal all_options_spawned

enum OPTIONS_ANCHOR {
	topLeft = 0,
	topRight = 1,
	bottomLeft = 2,
	bottomRight = 3
}
enum HECTIC_SECTION {
	left = 0,
	right = 1,
	top = 2
}

@export var optionsAnchor:OPTIONS_ANCHOR = OPTIONS_ANCHOR.topLeft

@onready var myLabel:Label3D = $DialogueLabel
var text:String = "":
	set(value):
		text = value
		myLabel.text = value
@onready var optionScene:Resource = preload(Globals.SCENES.DialogueOption)
@onready var optionSpawnPositions = {
	"normal": $OptionPositions/Normal.get_children(),
	"hecticSections": $OptionPositions/Hectic.get_children()
}
@onready var optionContainer = $OptionsContainer
@onready var warningTileScene:Resource = preload(Globals.SCENES.DialogueWarningTile)
@onready var warningAreas:Array = $WarningPositionAreas.get_children()
@onready var warningsContainer:Node3D = $WarningsContainer
@onready var timer:TimerBar = $Timer

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var currentDialogueID
var optionData:Array = []
var loadedOptions:Array = []
var mode:String = "normal"
var numWarnings:int = 6
var spawnedWarningTiles:Array = []

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
		timer.duration = 5.0  # TODO:  make this customizable
		timer.start()

func createOptions() -> void:
	var loadingDialogueID
	
	var prevDelay:float = 0.0
	for optionObjectData in optionData:
		loadingDialogueID = currentDialogueID
		
		var spawnDelay = max(optionObjectData.spawnDelay - prevDelay, 0)
		if spawnDelay > 0:
			await get_tree().create_timer(spawnDelay).timeout
			if loadingDialogueID != currentDialogueID:
				return
		prevDelay += spawnDelay
		
		var newOption:DialogueOption = spawnOption()
		configureOptionInstance(newOption, optionObjectData)
		newOption.spawn()
		new_option_available.emit()
	
	all_options_spawned.emit()

func spawnOption() -> DialogueOption:
	var option:DialogueOption = optionScene.instantiate()
	optionContainer.add_child(option)
	loadedOptions.push_back(option)
	return option

func setOptionPositionNormal(option:DialogueOption) -> void:
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

func setOptionAlignmentNormal(option:DialogueOption) -> void:
	match optionsAnchor:
		OPTIONS_ANCHOR.topLeft:
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.right
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.top
		OPTIONS_ANCHOR.topRight:
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.left
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.top
		OPTIONS_ANCHOR.bottomLeft:
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.right
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.bottom
		OPTIONS_ANCHOR.bottomRight:
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.left
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.bottom

func setOptionPositionHectic(option:DialogueOption, section:HECTIC_SECTION) -> void:
	# TODO:  maybe pick a position like we do with the warning tiles.
	var potentialPositions:Array = optionSpawnPositions.hecticSections[section].get_children()
	var newPosition:Marker3D = potentialPositions.pick_random()
	
	option.position = newPosition.position
	option.rotation_degrees = newPosition.rotation_degrees
	
	# TODO:  maybe figuree out a better way of removing a position from being chosen
	newPosition.queue_free()

func setOptionAlignmentHectic(option:DialogueOption, section:HECTIC_SECTION) -> void:
	match section:
		HECTIC_SECTION.left:
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.right
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.center
		HECTIC_SECTION.right:
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.left
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.center
		HECTIC_SECTION.top:
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.center
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.bottom

func configureOptionInstance(instance:DialogueOption, data:Dictionary) -> void:
	if mode == "normal":
		setOptionPositionNormal(instance)
		setOptionAlignmentNormal(instance)
	elif mode == "hectic":
		# TODO:  remove section opposite of options anchor so we don't overlap with NPCs
		#		 maybe just check for collision instead of relying on areas?
		#			would require spawning option in annd setting visible to check for collisions
		rng.randomize()
		var chosenSection:HECTIC_SECTION = rng.randi_range(0, HECTIC_SECTION.size()-1) as HECTIC_SECTION
		setOptionPositionHectic(instance, chosenSection)
		setOptionAlignmentHectic(instance, chosenSection)
	
	# TODO:  apply this aspect properly
	# Optional: if your DialogueOption supports lifetime
	if instance.has_method("set_lifetime") and data.has("lifetime"):
		instance.set_lifetime(float(data.get("lifetime", -1.0)))
	elif "lifetime" in instance:
		# If lifetime is a property, this will work too
		instance.lifetime = float(data.get("lifetime", -1.0))
	
	#instance.name = data.text
	instance.text = data.text
	instance.nextDialogue = data.nextID
	instance.connect("option_picked", _on_option_picked)

func spawnWarnings(amount:int) -> void:
	for _i in range(amount):
		var spawnLocation:Vector3 = getWarningTilePosition()
		
		var warningTile:WarningTile = warningTileScene.instantiate()
		warningsContainer.add_child(warningTile)
		spawnedWarningTiles.push_back(warningTile)
		
		warningTile.position = spawnLocation
		warningTile.look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)
		warningTile.connect("blocking_visual", _on_warning_tile_overlap)

func getWarningTilePosition() -> Vector3:
	# TODO:  round robin pick the areas instead
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



func _on_option_picked(data) -> void:
	for _i in range(loadedOptions.size()):
		var toKill:DialogueOption = loadedOptions.pop_front()
		toKill.kill()
	
	# TODO:  maybe create a small script for wa
	for _i in range(spawnedWarningTiles.size()):
		var toKill:WarningTile = spawnedWarningTiles.pop_front()
		toKill.kill()
	
	timer.stop()
	update_me.emit(data)

func _on_warning_tile_overlap(warningTile:WarningTile) -> void:
	# TODO:  move warning tile up and left/right instead of random position in area
	if warningTile.numTimesRepositioned > 3:
		return
	
	rng.randomize()
	var delay:float = rng.randf_range(0.0, 1.0)
	
	await get_tree().create_timer(delay).timeout
	if not warningTile:
		return
	
	warningTile.position = getWarningTilePosition()
	warningTile.numTimesRepositioned += 1
	warningTile.look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)

func _on_timer_bar_timeout() -> void:
	_on_option_picked("failure")
