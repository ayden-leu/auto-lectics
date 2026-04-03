extends Node3D
class_name DialogueBox

# TODO:  adjust size of dialogue box dynamically
# TODO:  verify/add signal emitions for all signals
# TODO:  make optionsAnchor configurable in dialogue .json file

## Emitted when the dialogue box wants to be updated.
signal update_me(nextID:String)
## Emitted when all of the dialogue text is visible.
signal all_dialogue_text_visible    # TODO
## Emitted when an option spawns.
signal new_option_available
## Emitted when all options are spawned.
signal all_options_available

## Used for referencing which corner of the dialogue box to start spawning options from.
enum OPTIONS_ANCHOR {
	topLeft,
	topRight,
	bottomLeft,
	bottomRight
}

## Lets you choose which corner of the dialogue box to start spawning options from. Options will spawn up/down accordingly. 
@export var optionsAnchor:OPTIONS_ANCHOR = OPTIONS_ANCHOR.topLeft
## Holds a reference to the text label that displays the current dialogue.
@export var myLabel:TypeWriterLabel
## Holds the text that displays the current dialogue.  Mainly just used as an easier way to get/set the label text.
var text:String = "":
	set(value):
		text = value
		myLabel.fullText = value

## Holds a reference to the dialogue option resource.
const optionScene:Resource = preload(Globals.SCENES.DialogueOption)
## Holds a reference to the warning tile resource.
const warningTileScene:Resource = preload(Globals.SCENES.DialogueWarningTile)

## Holds the available spawn positions for dialogue options for both modes.
@onready var optionSpawnPositions = {
	"normal": $OptionPositions/Normal.get_children(),
	"hectic": {
		"root": $OptionPositions/Hectic,
		"left": $OptionPositions/Hectic/Left.get_children(),
		"right": $OptionPositions/Hectic/Right.get_children(),
		"top": $OptionPositions/Hectic/Top.get_children(),
	}
}
## Holds all spawned options.
@onready var optionContainer = $OptionsContainer
## Holds the available spawn positions for warning tiles.
@onready var warningAreas:Array = $WarningPositionAreas.get_children()
## Holds all spawned warning tiles.
@onready var warningsContainer:Node3D = $WarningsContainer
## The timer bar that appears when a hectic dialogue object is loaded.
@onready var timer:TimerBar = $Timer
## Holds the AudioStreamPlayer3Ds for each event.
@onready var sfxPlayer:Dictionary[String, AudioStreamPlayer] = {
	"spawn": %spawn,
	"text": %text
}

## The owner of this dialogue box.
var realOwner
## A random number generator.
var rng:RandomNumberGenerator = RandomNumberGenerator.new()
## The ID of the current dialogue.
var currentDialogueID:String
## The ID of dialogue object to go to when the player fails a hectic dialogue interaction.
var hecticFailureDialogueID:String
## Holds the data for the options to spawn.
var optionData:Array = []
## Holds references to all spawned options.
var spawnedOptions:Array = []
## The dialogue mode.
var mode:String = "normal"
## The number of warning tiles to spawn during hectic mode.
var numWarnings:int = 6
## Holds references to all spawned warning tiles.
var spawnedWarningTiles:Array = []
## The SFX sound events to load sound files into.
var sfxEventsToLoad:Dictionary:
	set(value):
		sfxEventsToLoad = value
		loadSfx()
## How fast the text should be written in Characters per Second.
var textWriteSpeed:float
## Whether to start writing the text or not.
var increaseVisibleTextAmount:bool = false:
	set(value):
		increaseVisibleTextAmount = value
		timePassedSinceTextWriting = 0.0
## The amount of time passed since starting to write text.
var timePassedSinceTextWriting:float = 0.0
## A hardcoded delay between when the dialogue text finishes writing and when the options start being created.
var delayBtwnWriteDialogueAndOptions:float = 1.0

func _ready() -> void:
	if Engine.is_editor_hint():
		$WarningPositionAreas.visible = true
	else:
		$WarningPositionAreas.visible = false
	
func _process(delta: float) -> void:
	if increaseVisibleTextAmount:
		timePassedSinceTextWriting += delta
		writeText()

## Loads the data of all posible options for this dialogue object. Also sorts the options from shortest to longest spawn delay.
func loadOptionData(options: Array) -> void:
	optionData.clear()
	
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			continue
		
		#Don't show any options that don't pass check_flag
		var check_flags: Dictionary = option.checkFlags
		if StoryFlags.passes_check_flags(check_flags):
			optionData.push_back(option)
	
	optionData.sort_custom(func(a, b): return a.spawnDelay < b.spawnDelay)

## Runs any configurations that need to be run before continuing onward.
func prepare() -> void:
	if mode == "hectic":
		optionSpawnPositions.hectic.left = $OptionPositions/Hectic/Left.get_children()
		optionSpawnPositions.hectic.right = $OptionPositions/Hectic/Right.get_children()
		optionSpawnPositions.hectic.top = $OptionPositions/Hectic/Top.get_children()
		
		createWarningTiles(numWarnings)
		timer.duration = 5.0  # TODO:  make this customizable
		timer.start()

## Make the dialogue box start doing things.
func start() -> void:
	print("starting new dialogue")
	sfxPlayer.spawn.play()
	myLabel.visibleCharacters = 0
	increaseVisibleTextAmount = true

## Makes label text visible based on the elapsed time.
func writeText() -> void:
	var newVisibleAmount:int = roundi(timePassedSinceTextWriting * textWriteSpeed)
	myLabel.visibleCharacters = newVisibleAmount
	sfxPlayer.text.play()
	
	if newVisibleAmount >= text.length():
		finishWritingText()

func finishWritingText() -> void:
	increaseVisibleTextAmount = false
	all_dialogue_text_visible.emit()
	
	await get_tree().create_timer(delayBtwnWriteDialogueAndOptions).timeout
	
	if optionData.size() == 0:
		update_me.emit("")
		return
	
	createOptions()

## Loads the SFX from the files.
func loadSfx() -> void:
	for eventID in sfxPlayer.keys():
		AudioLoader.clearAudioFiles(sfxPlayer[eventID].stream)
		AudioLoader.loadAudioFiles(sfxEventsToLoad[eventID], sfxPlayer[eventID].stream)

## Creates each option that the player can choose from for this dialogue object.
func createOptions() -> void:
	var loadingDialogueID:String
	var prevDelay:float = 0.0
	
	for optionObjectData in optionData:
		loadingDialogueID = currentDialogueID
		
		var spawnDelay = max(optionObjectData.spawnDelay - prevDelay, 0.001)
		await get_tree().create_timer(spawnDelay).timeout
		if loadingDialogueID != currentDialogueID:
			return
		prevDelay += spawnDelay - 0.001
		
		var newOption:DialogueOption = spawnOption()
		configureDialogueOption(newOption, optionObjectData)
		newOption.prepare()
		new_option_available.emit()
	
	all_options_available.emit()

## Creates a dialogue option scene and saves a reference to it in "spawnedOptions"
func spawnOption() -> DialogueOption:
	var option:DialogueOption = optionScene.instantiate()
	optionContainer.add_child(option)
	spawnedOptions.push_back(option)
	return option

## Updates the position of a dialogue option in normal mode.
func setOptionPositionNormal(option:DialogueOption) -> void:
	if spawnedOptions.size() == 1:
		option.position = optionSpawnPositions.normal[optionsAnchor].position
		option.rotation_degrees = optionSpawnPositions.normal[optionsAnchor].rotation_degrees
		return
	
	var lastOption:DialogueOption = spawnedOptions[-2]
	var offsetMultiplier:float = 1.001
	if optionsAnchor == OPTIONS_ANCHOR.bottomLeft or optionsAnchor == OPTIONS_ANCHOR.bottomRight:
		offsetMultiplier *= -1
	
	option.position = lastOption.position + Vector3(0, -lastOption.labelHeight * offsetMultiplier, 0)
	option.rotation_degrees = lastOption.rotation_degrees

## Updates the alignment of a dialogue option in normal mode.
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

## Updates the position of a dialogue option in hectic mode.
func setOptionPositionHectic(option:DialogueOption, section:String) -> void:
	# TODO:  pick a position like we do with the warning tiles.
	#			its technically possible to run out of positions
	var potentialPositions:Array = optionSpawnPositions.hectic[section]
	for usedPosition in optionSpawnPositions.hectic.root.usedPositions:
		potentialPositions.erase(usedPosition)
	
	var newPosition:Marker3D = potentialPositions.pick_random()
	optionSpawnPositions.hectic.root.usedPositions.push_back(newPosition)
	
	option.position = newPosition.position
	option.rotation_degrees = newPosition.rotation_degrees

## Updates the alignment of a dialogue option in hectic mode.
func setOptionAlignmentHectic(option:DialogueOption, section:String) -> void:
	match section:
		"left":
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.right
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.center
		"right":
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.left
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.center
		"top":
			option.horizontalAlignment = option.HORIZONTAL_ALIGNMENT.center
			option.verticalAlignment = option.VERTICAL_ALIGNMENT.bottom
		_:
			printerr("DialogueBox: Unexpected section value. Got: ", section)

## Gets the appropriate general areas to spawn dialogue options in depending on "optionsAnchor"
func getValidHecticAreas() -> Array[String]:
	var toReturn:Array[String] = ["left", "right", "top"]
	if optionSpawnPositions.hectic.left.size() == 0:
		toReturn.erase("left")
	if optionSpawnPositions.hectic.right.size() == 0:
		toReturn.erase("right")
	if optionSpawnPositions.hectic.top.size() == 0:
		toReturn.erase("top")
	
	match optionsAnchor:
		OPTIONS_ANCHOR.topLeft:
			toReturn.erase("right")
		OPTIONS_ANCHOR.topRight:
			toReturn.erase("left")
		OPTIONS_ANCHOR.bottomLeft:
			toReturn.erase("right")
			toReturn.erase("top")
		OPTIONS_ANCHOR.bottomRight:
			toReturn.erase("left")
			toReturn.erase("top")
		_:
			printerr("DialogueBox: optionsAnchor value not accounted for")
			return ["???"]
	
	return toReturn

## Configures aspects of a dialogue option.
func configureDialogueOption(instance:DialogueOption, data:Dictionary) -> void:
	instance.sfxEventsToLoad = data.sfx
	
	if mode == "normal":
		setOptionPositionNormal(instance)
		setOptionAlignmentNormal(instance)
	elif mode == "hectic":
		var chosenSection:String = getValidHecticAreas().pick_random()
		setOptionPositionHectic(instance, chosenSection)
		setOptionAlignmentHectic(instance, chosenSection)
	else:
		printerr("DialogueBox: Mode is not set to 'normal' or 'hectic.' Got: ", mode)
	
	#instance.name = data.text
	instance.text = data.text
	instance.nextDialogueID = data.nextID
	instance.lifetime = data.lifetime
	instance.setFlags = data.setFlags
	#instance.connect("option_picked", _on_option_picked.bind(instance))
	instance.option_picked.connect(_on_option_picked)

## Creates "amount" warning tiles.
func createWarningTiles(amount:int) -> void:
	for _i in range(amount):
		var warningTile:WarningTile = spawnWarningTile()
		configureWarningTile(warningTile)

## Creates a warning tile scene and saves a reference to it in "spawnedWarningTiles"
func spawnWarningTile() -> WarningTile:
	var warningTile:WarningTile = warningTileScene.instantiate()
	warningsContainer.add_child(warningTile)
	spawnedWarningTiles.push_back(warningTile)
	return warningTile

## Configures a warning tile.
func configureWarningTile(warningTile:WarningTile) -> void:
	warningTile.position = getWarningTilePosition()
	warningTile.lookAtCamera()
	warningTile.connect("blocking_visual", _on_warning_tile_overlap)

## Gets a valid position to move a warning tile to based on the pre-configured WarningPositionAreas.
func getWarningTilePosition() -> Vector3:
	# TODO:  maybe make sure each area is picked at least once before picking again?
	var chosenArea:MeshInstance3D = warningAreas.pick_random()
	var maxOffset:Vector3 = chosenArea.mesh.get_aabb().size
	
	rng.randomize()
	var offset:Vector3 = Vector3(
		rng.randf_range(-maxOffset.x, maxOffset.x),
		rng.randf_range(-maxOffset.y, maxOffset.y),
		rng.randf_range(-maxOffset.z, maxOffset.z)
	)
	return chosenArea.position + offset

## Removes the dialogue box from the world.
func kill() -> void:
	for eventID in sfxPlayer.keys():
		AudioLoader.clearAudioFiles(sfxPlayer[eventID].stream)
	queue_free()


## Handles logic for when a dialogue option is picked.
func _on_option_picked(pickedOption:DialogueOption, nextDialogueID:String) -> void:
	if pickedOption:
		StoryFlags.apply_set_flags(pickedOption.setFlags)

	for _i in range(spawnedOptions.size()):
		var toKill = spawnedOptions.pop_front()
		if toKill:
			toKill.kill()
	optionSpawnPositions.hectic.root.usedPositions.clear()
	
	for _i in range(spawnedWarningTiles.size()):
		var toKill:WarningTile = spawnedWarningTiles.pop_front()
		toKill.kill()
	
	timer.stop()
	#print("\nnext dialogue: ", nextDialogueID)
	sfxPlayer.spawn.stop()
	update_me.emit(nextDialogueID)

## Handles logic for when an option isn't picked in time during hectic mode.
func _on_timer_bar_timeout() -> void:
	if hecticFailureDialogueID == "":
		if realOwner != null:
			printerr("DialogueBox: Hectic Failure Dialogue ID not set for: ", realOwner.name)
		else:
			printerr("DialogueBox: Hectic Failure Dialogue ID not set for whoever loads this dialogue: ", currentDialogueID)
			printerr("DialogueBox: Also, realOwner variable not set.")
	_on_option_picked(null, hecticFailureDialogueID)




## Handles logic for when a warning tile is blocking an important subject.
func _on_warning_tile_overlap(warningTile:WarningTile) -> void:
	if warningTile.numTimesRepositioned > 3:
		return
	
	rng.randomize()
	var delay:float = rng.randf_range(0.0, 1.0)
	await get_tree().create_timer(delay).timeout
	
	# it's possible for the dialogue box to kill() in between the delay starting and stopping.
	if not warningTile:
		return
	
	# TODO:  maybe move warning tile up and left/right instead of random position in area
	warningTile.position = getWarningTilePosition()
	warningTile.lookAtCamera()
	warningTile.numTimesRepositioned += 1
