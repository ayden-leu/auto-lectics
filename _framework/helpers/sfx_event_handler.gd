@tool
extends Node
class_name SfxEventHandler
## A helper class to add SFX events that are loaded with sound files from [AudioLoader].
##
## To use, add the pre-built [SfxEventHandler] scene to your current scene.
## You cannot add it through the "Create New Node" dialogue due to it acting differently.
## [br][br]
## To add an event, attach an [AudioStreamPlayer] or those that inherit it to this node.
## The name of this node will be the event name.
## [br][br]
## [b]IMPORTANT:  If you care about the position of the [AudioStreamPlayer]s, you shouldn't use this
## as the position relative to the parent won't automatically be inherited. [/b]
## [br][br]
## You can then enter the SFX ID for each SFX event in the [member sfxIds] export field on the right panel.
## The audio files for each SFX ID will then be loaded by the [AudioLoader]
## when this node is loaded in-game.
## If you don't want a sound to play for a SFX event, you can leave it blank.
## [br][br]
## To play one of these events, call [method play].
## [br][br]
## To get the [AudioStreamPlayer] responsible for an event, use the result of [method getPlayerForEvent].

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## Holds the SFX ID for each SFX event to be loaded with [AudioLoader].
@export var sfxIds:Dictionary[String, String] = {}

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The [AudioStreamPlayer]s that play the sounds for each SFX event.
var _sfxPlayers:Array[AudioStreamPlayer] = []
## [b]Internal-use only.[/b]
## Maps [AudioStreamPlayer]s to their SFX event name.
## You can also just reference the [AudioStreamPlayer]'s name.
var _sfxPlayerToEventName:Dictionary[AudioStreamPlayer, String] = {}
## [b]Internal-use only.[/b]
## Maps SFX event names to [AudioStreamPlayer]s.
var _sfxEventNameToPlayer:Dictionary[String, AudioStreamPlayer] = {}
## [b]Internal-use only.[/b]
## If this is currently sorting the nodes or not.
var _sorting:bool = false
## [b]Internal-use only.[/b]
## If this is currently loading things or not.
var _loading:bool = true

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# initialize variables and audio for when the game is being played
	for child in get_children():
		if child is not AudioStreamPlayer:
			continue
		var trueChild:AudioStreamPlayer = child as AudioStreamPlayer
		_addToVariables(trueChild)
	AudioLoader.loadSfxIntoPlayers(sfxIds, _sfxEventNameToPlayer)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Plays the sound for the SFX given event name.
func play(eventName:String) -> void:
	if eventName == "buttonPressed" or "guessNpcNameTextChanged":
		return
	var player:AudioStreamPlayer = _sfxEventNameToPlayer[eventName]
	if player == null:
		printerr("SfxEventHandler:  Could not find event player of name [", eventName, "]")
		return

	print("SfxEventHandler:  Playing ", eventName)

	player.stop()
	player.play()

## Stops the sound for the SFX given event name.
func stop(eventName:String) -> void:
	var player:AudioStreamPlayer = _sfxEventNameToPlayer[eventName]
	if player == null:
		printerr("SfxEventHandler:  Could not find event player of name [", eventName, "]")
		return

	print("SfxEventHandler:  Stopping ", eventName)

	player.stop()

## Returns the [AudioStreamPlayer] for the given SFX event name.
## Returns [code]null[/code] if it can't find one.
func getPlayerForEvent(eventName:String) -> AudioStreamPlayer:
	var player:AudioStreamPlayer = _sfxEventNameToPlayer.get(eventName)
	if not player:
		print("SfxEventHandler:  Could not find an AudioStreamPlayer for event [", eventName, "]")

	return player

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Adds the given [AudioStreamPlayer] to internal tracking variables.
func _addToVariables(player:AudioStreamPlayer) -> void:
	_sfxPlayers.push_back(player)
	_sfxPlayerToEventName[player] = player.name
	_sfxEventNameToPlayer[player.name] = player

## [b]Internal-use only.[/b]
## Removes the given [AudioStreamPlayer] to internal tracking variables.
func _removeFromVariables(player:AudioStreamPlayer) -> void:
	_sfxPlayers.erase(player)
	_sfxPlayerToEventName.erase(player)
	_sfxEventNameToPlayer.erase(player.name)

## [b]Internal-use only.[/b]
## Removes an old SFX event entry in [member sfxIds] and adds a new entry
## based on the old and new name of the event, respectively.
func _updateEventNameFromPlayer(player:AudioStreamPlayer) -> void:
	# only do stuff if it was renamed
	var oldName:String = _sfxPlayerToEventName[player]
	if oldName == null:
		print("SfxEventHandler:  AudioStreamPlayer not found in _sfxPlayerToEventName.")
		return
	if oldName == player.name:
		return

	print("SfxEventHandler:  Updating event name [", oldName, "] to [", player.name, "]")
	_sfxPlayerToEventName[player] = player.name
	sfxIds.erase(oldName)
	sfxIds[player.name] = ""

	# sort internal tracking and node layout
	sfxIds.sort()
	var temp:Array = sfxIds.keys()
	var index:int = temp.find(player.name)
	move_child(player, index)

## [b]Internal-use only.[/b]
## Adds an entry into [member sfxIds], along with other internal variables.
func _addEntryToSfxIds(player:AudioStreamPlayer) -> void:
	_addToVariables(player)
	sfxIds = sfxIds.duplicate(true)  # needed to avoid an error
	sfxIds[player.name] = ""
	player.renamed.connect(_on_child_renamed.bind(player))
	notify_property_list_changed()

## [b]Internal-use only.[/b]
## Handles the removal of an [AudioStreamPlayer] child.
func _actuallyRemovePlayer(player:AudioStreamPlayer) -> void:
	_removeFromVariables(player)
	sfxIds.erase(player.name)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when a new node is added as a child to this node.
func _on_child_entered_tree(node: Node) -> void:
	if _sorting or _loading:
		return
	if node is not AudioStreamPlayer:
		return
	var child:AudioStreamPlayer = node

	_addEntryToSfxIds(child)
	child.stream = AudioStreamRandomizer.new()

## [b]Internal-use only.[/b]
## Handles logic for when a child is removed from this node.
func _on_child_exiting_tree(node: Node) -> void:
	if _sorting or _loading:
		return
	if node is not AudioStreamPlayer:
		return
	var child:AudioStreamPlayer = node

	# needed because switching scenes counts as exiting tree
	# without it, sfxIDs values don't persist
	await get_tree().create_timer(0.01).timeout
	if not _loading:
		_actuallyRemovePlayer(child)

## [b]Internal-use only.[/b]
## Handles logic for when a child of this is node is renamed.
func _on_child_renamed(child:AudioStreamPlayer) -> void:
	print("eggs")
	_updateEventNameFromPlayer(child)

func _on_tree_entered() -> void:
	if not Engine.is_editor_hint():
		return
	call_deferred("_continue_on_tree_entered")
func _continue_on_tree_entered() -> void:
	_loading = false

	# failsafe in case there are AudioStreamPlayer children but
	# the sfxIds list is empty for some reason.
	if sfxIds.is_empty():
		sfxIds = sfxIds.duplicate(true)  # needed to avoid an error
		for child in get_children():
			if child is not AudioStreamPlayer:
				continue
			sfxIds[child.name] = ""

func _on_tree_exiting() -> void:
	_loading = true

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	for sfxPlayer in _sfxPlayers:
		if sfxPlayer.stream == null:
			warnings.push_back(
				"SFX player for event \"" + sfxPlayer.name + "\" doesn't have a resource set.  " +
				"It should be a Randomizer resource."
			)
		elif sfxPlayer.stream is not AudioStreamRandomizer:
			warnings.push_back(
				"SFX player for event \"" + sfxPlayer.name + "\" should be a Randomizer resource."
			)
		#elif sfxIds[sfxPlayer.name] == "":
			#warnings.push_back(
				#"SFX event \"" + sfxPlayer.name + "\" doesn't have an entry in SFX IDs."
			#)

	return warnings
