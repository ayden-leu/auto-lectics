extends Node3D
class_name DialogueBox
## @deprecated
## [b]Internal-use only.[/b]  The dialogue box that spawns when a dialogue event is happening.
## Forward is in the positive X direction.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the dialogue box wants to be updated.
signal update_me(nextID:String)
## Emitted when all of the dialogue text is visible.
signal all_dialogue_text_visible()
## Emitted when an option spawns.
signal new_option_available()
## Emitted when all options are spawned.
signal all_options_available()

# ------------------------------------------------
# enums
# ------------------------------------------------
## [b]Internal-use only.[/b]  Used for referencing which corner of the dialogue box to start spawning options from.
enum _OptionAnchor {
	TOP_LEFT,    ## Options are right-aligned and appear on the top-left corner.
	TOP_RIGHT,   ## Options are left-aligned and appear on the top-right corner.
	BOTTOM_LEFT, ## Options are right-aligned and appear on the bottom-left corner.
	BOTTOM_RIGHT ## Options are left-aligned and appear on the bottom-right corner.
}

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]  Holds a reference to the dialogue option resource.
const _OPTION_SCENE:Resource = preload(FR_Globals.SCENES.DialogueBoxOption)
## [b]Internal-use only.[/b]  Holds a reference to the warning tile resource.
const _WARNING_TILE_SCENE:Resource = preload(FR_Globals.SCENES.DialogueWarningTile3D)
## [b]Internal-use only.[/b]  The number of warning tiles to spawn during hectic mode.
const _NUM_WARNINGS:int = 6

# ------------------------------------------------
# export variables
# ------------------------------------------------
## Lets you choose which corner of the dialogue box to start spawning options from. Options will spawn up/down accordingly. 
@export var _optionsAnchor:_OptionAnchor = _OptionAnchor.TOP_LEFT
## The label that displays the current dialogue.
@export var _myLabel:TypeWriterLabel3D

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  Holds the available spawn positions for dialogue options for both modes.
## Not constant as the hectic sub-fields get modified.
@onready var _optionSpawnPositions = {
	"normal": $OptionPositions/Normal.get_children(),
	"hectic": {
		"root": $OptionPositions/Hectic,
		"left": $OptionPositions/Hectic/Left.get_children(),
		"right": $OptionPositions/Hectic/Right.get_children(),
		"top": $OptionPositions/Hectic/Top.get_children(),
	}
}
## [b]Internal-use only.[/b]   Holds all spawned options.
@onready var _optionContainer = %OptionsContainer
## [b]Internal-use only.[/b]   Holds all spawned warning tiles.
@onready var _warningsContainer:Node3D = %WarningsContainer
## [b]Internal-use only.[/b]   Holds the available spawn positions for warning tiles.
@onready var _warningAreas:Array = $WarningPositionAreas.get_children()
## [b]Internal-use only.[/b]   The timer bar that appears when a hectic dialogue object is loaded.
@onready var _timer:TimerBar = %Timer
## [b]Internal-use only.[/b]   Holds the AudioStreamPlayer3Ds for each event.
@onready var _sfxPlayers:Dictionary[String, AudioStreamPlayer3D] = {
	"spawn": %SFX/spawn,
	"text": %SFX/text
}

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Holds the text that displays the current dialogue.  Mainly just used as an easier way to get/set the label text.
var text:String = "":
	set(value):
		text = value
		_myLabel.fullText = value
## The owner of this dialogue box.  Can't use [method get_parent()] due to the immediate parent not always being the thing that spawned this. 
var realOwner:Node3D
## The ID of the current dialogue.
var currentDialogueID:String
## The ID of dialogue object to go to when the player fails a hectic dialogue interaction.
var hecticFailureDialogueID:String
## The dialogue mode.
var mode:String = "normal"
## How fast the text should be written in Characters per Second.
var textWriteSpeed:float
## A hardcoded delay between when the dialogue text finishes writing and when the options start being created.
var delayBtwnWriteDialogueAndOptions:float = 1.0
## A hardcoded delay between when the dialogue text finishes writing and when the options start being created.
var delayBtwnWriteDialogueAndOptionsHectic:float = 0.25

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  A random number generator.
var _rng:RandomNumberGenerator = RandomNumberGenerator.new()
## [b]Internal-use only.[/b]  Holds the data for the options to spawn.
var _optionData:Array = []
## [b]Internal-use only.[/b]  Holds references to all spawned options.
var _spawnedOptions:Array = []
## [b]Internal-use only.[/b]  Holds references to all spawned warning tiles.
var _spawnedWarningTiles:Array = []
## [b]Internal-use only.[/b]  Whether to start writing the text or not.
var _increaseVisibleTextAmount:bool = false:
	set(value):
		_increaseVisibleTextAmount = value
		_timePassedSinceTextWriting = 0.0
## [b]Internal-use only.[/b]  The amount of time passed since starting to write text.
var _timePassedSinceTextWriting:float = 0.0

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		$WarningPositionAreas.visible = true
	else:
		$WarningPositionAreas.visible = false
	
func _process(delta: float) -> void:
	if _increaseVisibleTextAmount:
		_timePassedSinceTextWriting += delta
		_writeText()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Runs any configurations that need to be run before continuing onward.
func prepare() -> void:
	if mode == "hectic":
		_optionSpawnPositions.hectic.left = $OptionPositions/Hectic/Left.get_children()
		_optionSpawnPositions.hectic.right = $OptionPositions/Hectic/Right.get_children()
		_optionSpawnPositions.hectic.top = $OptionPositions/Hectic/Top.get_children()
		
		_createWarningTiles(_NUM_WARNINGS)
		_timer.duration = 5.0  # TODO:  make this customizable
		_timer.start()

## Make the dialogue box start doing things.
func start() -> void:
	_sfxPlayers.spawn.play()
	_myLabel.visibleCharacters = 0
	_increaseVisibleTextAmount = true

## Loads the data of all posible options for this dialogue object. Also sorts the options from shortest to longest spawn delay.
func loadOptionData(options: Array) -> void:
	_optionData.clear()
	
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			continue
		
		#Don't show any options that don't pass check_flag
		var check_flags: Dictionary = option.checkFlags
		if StoryFlags.flagsMatch(check_flags):
			_optionData.push_back(option)
	
	_optionData.sort_custom(func(a, b): return a.spawnDelay < b.spawnDelay)

## Loads the SFX from the files.
func loadSfx(sfxEventsToLoad:Dictionary) -> void:
	for eventID in _sfxPlayers.keys():
		AudioLoader.clearAudioRandomizer(_sfxPlayers[eventID].stream)
		AudioLoader.loadSfxFromId(sfxEventsToLoad[eventID], _sfxPlayers[eventID].stream)

## Removes the dialogue box from the world.
func kill() -> void:
	for eventID in _sfxPlayers.keys():
		AudioLoader.clearAudioRandomizer(_sfxPlayers[eventID].stream)
	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Makes label text visible based on the elapsed time.
func _writeText() -> void:
	var newVisibleAmount:int = roundi(_timePassedSinceTextWriting * textWriteSpeed)
	_myLabel.visibleCharacters = newVisibleAmount
	_sfxPlayers.text.play()
	
	if newVisibleAmount >= text.length():
		_finishWritingText()

## [b]Internal-use only.[/b]  Handles stuff that needs to happen when the text
## finishes being displayed.
func _finishWritingText() -> void:
	_increaseVisibleTextAmount = false
	all_dialogue_text_visible.emit()
	
	var delay:float = delayBtwnWriteDialogueAndOptions \
		if hecticFailureDialogueID == "" \
		else delayBtwnWriteDialogueAndOptionsHectic
	await get_tree().create_timer(delay).timeout
	
	if _optionData.size() == 0:
		update_me.emit("")
		return
	
	_createOptions()

## [b]Internal-use only.[/b]  Creates each option that the player can choose from for this dialogue object.
func _createOptions() -> void:
	var loadingDialogueID:String
	var prevDelay:float = 0.0
	
	for optionObjectData in _optionData:
		loadingDialogueID = currentDialogueID
		
		var spawnDelay = max(optionObjectData.spawnDelay - prevDelay, 0.001)
		await get_tree().create_timer(spawnDelay).timeout
		if loadingDialogueID != currentDialogueID:
			return
		prevDelay += spawnDelay - 0.001
		
		var newOption:DialogueBoxOption = _spawnOption()
		_configureDialogueBoxOption(newOption, optionObjectData)
		newOption.prepare()
		new_option_available.emit()
	
	all_options_available.emit()

## [b]Internal-use only.[/b]  Creates a dialogue option scene and saves a reference to it in "_spawnedOptions"
func _spawnOption() -> DialogueBoxOption:
	var option:DialogueBoxOption = _OPTION_SCENE.instantiate()
	_optionContainer.add_child(option)
	_spawnedOptions.push_back(option)
	return option

## [b]Internal-use only.[/b]  Updates the position of a dialogue option in normal mode.
func _setOptionPositionNormal(option:DialogueBoxOption) -> void:
	if _spawnedOptions.size() == 1:
		option.position = _optionSpawnPositions.normal[_optionsAnchor].position
		option.rotation_degrees = _optionSpawnPositions.normal[_optionsAnchor].rotation_degrees
		return
	
	var lastOption:DialogueBoxOption = _spawnedOptions[-2]
	var offsetMultiplier:float = 1.001
	if _optionsAnchor == _OptionAnchor.BOTTOM_LEFT or _optionsAnchor == _OptionAnchor.BOTTOM_RIGHT:
		offsetMultiplier *= -1
	
	option.position = lastOption.position + Vector3(0, -lastOption.labelHeight * offsetMultiplier, 0)
	option.rotation_degrees = lastOption.rotation_degrees

## [b]Internal-use only.[/b]  Updates the alignment of a dialogue option in normal mode.
func _setOptionAlignmentNormal(option:DialogueBoxOption) -> void:
	match _optionsAnchor:
		_OptionAnchor.TOP_LEFT:
			option.horizontalAlignment = option.HorizAlignment.RIGHT
			option.verticalAlignment = option.VertiAlignment.TOP
		_OptionAnchor.TOP_RIGHT:
			option.horizontalAlignment = option.HorizAlignment.LEFT
			option.verticalAlignment = option.VertiAlignment.TOP
		_OptionAnchor.BOTTOM_LEFT:
			option.horizontalAlignment = option.HorizAlignment.RIGHT
			option.verticalAlignment = option.VertiAlignment.BOTTOM
		_OptionAnchor.BOTTOM_RIGHT:
			option.horizontalAlignment = option.HorizAlignment.LEFT
			option.verticalAlignment = option.VertiAlignment.BOTTOM

## [b]Internal-use only.[/b]  Updates the position of a dialogue option in hectic mode.
func _setOptionPositionHectic(option:DialogueBoxOption, section:String) -> void:
	var potentialPositions:Array = _optionSpawnPositions.hectic[section]
	for usedPosition in _optionSpawnPositions.hectic.root.usedPositions:
		potentialPositions.erase(usedPosition)
	
	var newPosition:Marker3D = potentialPositions.pick_random()
	_optionSpawnPositions.hectic.root.usedPositions.push_back(newPosition)
	
	option.position = newPosition.position
	option.rotation_degrees = newPosition.rotation_degrees

## [b]Internal-use only.[/b]  Updates the alignment of a dialogue option in hectic mode.
func _setOptionAlignmentHectic(option:DialogueBoxOption, section:String) -> void:
	match section:
		"left":
			option.horizontalAlignment = option.HorizAlignment.RIGHT
			option.verticalAlignment = option.VertiAlignment.CENTER
		"right":
			option.horizontalAlignment = option.HorizAlignment.LEFT
			option.verticalAlignment = option.VertiAlignment.CENTER
		"top":
			option.horizontalAlignment = option.HorizAlignment.CENTER
			option.verticalAlignment = option.VertiAlignment.BOTTOM
		_:
			printerr("DialogueBox: Unexpected section value. Got: ", section)

## [b]Internal-use only.[/b]  Gets the appropriate general areas to spawn dialogue options in depending on "_optionsAnchor"
func _getValidHecticAreas() -> Array[String]:
	var toReturn:Array[String] = ["left", "right", "top"]
	if _optionSpawnPositions.hectic.left.size() == 0:
		toReturn.erase("left")
	if _optionSpawnPositions.hectic.right.size() == 0:
		toReturn.erase("right")
	if _optionSpawnPositions.hectic.top.size() == 0:
		toReturn.erase("top")
	
	match _optionsAnchor:
		_OptionAnchor.TOP_LEFT:
			toReturn.erase("right")
		_OptionAnchor.TOP_RIGHT:
			toReturn.erase("left")
		_OptionAnchor.BOTTOM_LEFT:
			toReturn.erase("right")
			toReturn.erase("top")
		_OptionAnchor.BOTTOM_RIGHT:
			toReturn.erase("left")
			toReturn.erase("top")
		_:
			printerr("DialogueBox: _optionsAnchor value not accounted for")
			return ["???"]
	
	return toReturn

## [b]Internal-use only.[/b]  Configures aspects of a dialogue option.
func _configureDialogueBoxOption(option:DialogueBoxOption, data:Dictionary) -> void:
	option.sfxEventsToLoad = data.sfx
	
	if mode == "normal":
		_setOptionPositionNormal(option)
		_setOptionAlignmentNormal(option)
	elif mode == "hectic":
		var chosenSection:String = _getValidHecticAreas().pick_random()
		_setOptionPositionHectic(option, chosenSection)
		_setOptionAlignmentHectic(option, chosenSection)
	else:
		printerr("DialogueBox: Mode is not set to 'normal' or 'hectic.' Got: ", mode)
	
	#instance.name = data.text
	option.text = data.text
	option.nextDialogueID = data.nextID
	option.lifetime = data.lifetime
	option.setFlags = data.setFlags
	option.option_picked.connect(_on_option_picked)

## [b]Internal-use only.[/b]  Creates "amount" warning tiles.
func _createWarningTiles(amount:int) -> void:
	for _i in range(amount):
		var warningTile:WarningTile3D = _spawnWarningTile()
		_configureWarningTile(warningTile)

## [b]Internal-use only.[/b]  Creates a warning tile scene and saves a reference to it in "_spawnedWarningTiles"
func _spawnWarningTile() -> WarningTile3D:
	var warningTile:WarningTile3D = _WARNING_TILE_SCENE.instantiate()
	_warningsContainer.add_child(warningTile)
	_spawnedWarningTiles.push_back(warningTile)
	return warningTile

## [b]Internal-use only.[/b]  Configures a warning tile.
func _configureWarningTile(warningTile:WarningTile3D) -> void:
	warningTile.position = _getWarningTilePosition()
	warningTile.lookAtCamera()
	warningTile.connect("blocking_visual", _on_warning_tile_overlap)

## [b]Internal-use only.[/b]  Gets a valid position to move a warning tile to based on the pre-configured WarningPositionAreas.
func _getWarningTilePosition() -> Vector3:
	# TODO:  maybe make sure each area is picked at least once before picking again?
	var chosenArea:MeshInstance3D = _warningAreas.pick_random()
	var maxOffset:Vector3 = chosenArea.mesh.get_aabb().size
	
	_rng.randomize()
	var offset:Vector3 = Vector3(
		_rng.randf_range(-maxOffset.x, maxOffset.x),
		_rng.randf_range(-maxOffset.y, maxOffset.y),
		_rng.randf_range(-maxOffset.z, maxOffset.z)
	)
	return chosenArea.position + offset

## [b]Internal-use only.[/b]  Kills all spawned [DialogueBoxOption]s
## in [member _spawnedOptions].
func _killAllOptions() -> void:
	for _i in range(_spawnedOptions.size()):
		var toKill = _spawnedOptions.pop_front()
		if toKill:
			toKill.kill()
	_optionSpawnPositions.hectic.root.usedPositions.clear()

## [b]Internal-use only.[/b]  Deletes all spawned [WarningTile3D]s
## in [member _spawnedWarningTiles]
func _deleteAllWarningTiles() -> void:
	for _i in range(_spawnedWarningTiles.size()):
		var toKill:WarningTile3D = _spawnedWarningTiles.pop_front()
		toKill.kill()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when a dialogue option is picked.
func _on_option_picked(pickedOption:DialogueBoxOption, nextDialogueID:String) -> void:
	if pickedOption:
		StoryFlags.updateFlags(pickedOption.setFlags)
	
	_killAllOptions()
	_deleteAllWarningTiles()
	
	_timer.stop()
	#print("\nnext dialogue: ", nextDialogueID)
	_sfxPlayers.spawn.stop()
	update_me.emit(nextDialogueID)

## [b]Internal-use only.[/b]  Runs when an option isn't picked in time during hectic mode.
func _on_timer_bar_timeout() -> void:
	if hecticFailureDialogueID == "":
		if realOwner != null:
			printerr("DialogueBox: Hectic Failure Dialogue ID not set for: ", realOwner.name)
		else:
			printerr("DialogueBox: Hectic Failure Dialogue ID not set for whoever loads this dialogue: ", currentDialogueID)
			printerr("DialogueBox: Also, realOwner variable not set.")
	_on_option_picked(null, hecticFailureDialogueID)

## [b]Internal-use only.[/b]  Runs when a warning tile is blocking an important subject.
func _on_warning_tile_overlap(warningTile:WarningTile3D) -> void:
	if warningTile.numTimesRepositioned > 3:
		return
	
	_rng.randomize()
	var delay:float = _rng.randf_range(0.0, 1.0)
	await get_tree().create_timer(delay).timeout
	
	# it's possible for the dialogue box to kill() in between the delay starting and stopping.
	if not warningTile:
		return
	
	warningTile.position = _getWarningTilePosition()
	warningTile.lookAtCamera()
	warningTile.numTimesRepositioned += 1

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
