@tool
@icon("uid://cid3iipxpm568")
extends Control
class_name Menu

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this menu wants to be closed.
signal close_me()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## Holds all of the [AudioStreamPlayer]s for each SFX event.
@export var sfxPlayers:Dictionary[String, AudioStreamPlayer] = {
	"open": null,
	"close": null
}
## Holds the SFX ID for each SFX event.
## [br]
## If you plan to load audio into a SFX event through another way, you can leave it blank.
@export var sfxIds:Dictionary[String, String] = {
	"open": "",
	"close": ""
}

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The ID of this menu.
var menuID:String
## Whether this menu pauses the game or not.
var pausesGame:bool = true

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  The default process mode for a menu.
## Currently, it's set to only process when [member SceneTree.paused] is true.
var _defaultProcessMode:ProcessMode = Node.PROCESS_MODE_ALWAYS

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	process_mode = _defaultProcessMode
	z_index = FR_Globals.MENU_Z_INDEX
	AudioLoader.loadSfxIntoPlayers(sfxIds, sfxPlayers)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Enables this menu's processing and makes it visible.
func enable() -> void:
	visible = true
	process_mode = _defaultProcessMode

	sfxPlayers.open.stop()
	sfxPlayers.open.play()

## Disables this menu's processing and makes it not visible
func disable() -> void:
	visible = false
	process_mode = PROCESS_MODE_DISABLED

	sfxPlayers.close.stop()
	sfxPlayers.close.play()

## Primes this menu to be closed.
func close() -> void:
	close_me.emit()

## Force-kills this menu.  Should only be ran by the [MenuManager].
func delete() -> void:
	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs logic for when the close button is pressed.
func _on_close_button_pressed() -> void:
	close()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	for sfxEvent in sfxPlayers:
		if sfxPlayers[sfxEvent] == null:
			warnings.push_back(
				"SFX player for event \"" + sfxEvent + "\" not set."
			)
		elif sfxPlayers[sfxEvent].stream == null:
			warnings.push_back(
				"SFX player for event \"" + sfxEvent + "\" doesn't have a resource set.  " +
				"It should be a Randomizer resource."
			)
		elif sfxIds.get(sfxEvent) == null:
			warnings.push_back(
				"SFX event \"" + sfxEvent + "\" doesn't have an entry in SFX IDs."
			)

	return warnings
