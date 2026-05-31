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

@export var sfxEventHandler:SfxEventHandler

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
	z_index = MenuManager.MENU_Z_INDEX

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Enables this menu's processing and makes it visible.
func enable() -> void:
	visible = true
	process_mode = _defaultProcessMode

## Disables this menu's processing and makes it not visible
func disable() -> void:
	visible = false
	process_mode = PROCESS_MODE_DISABLED

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
