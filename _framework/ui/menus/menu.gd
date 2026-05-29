@tool
@icon("uid://cid3iipxpm568")
extends Control
class_name Menu
## A base class for all full-screen HUD elements managed by [MenuManager].
##
## The setup for a [Menu] is pretty minimal.
## You don't need to add anything to make one "functional."
## Just make sure to use the "Default" script template when making a new script for it.
## You'll know if you did it properly if the [method _ready] function has an
## incomplete line for setting [member menuID].
## [br][br]
## If you decide to add a close button (you should), there is already a function
## provided to handle it being pressed ([method _on_close_button_pressed]),
## so you can connect that button's [code]pressed[/code] signal to that function.
## [br][br]
## If you decide to "overwrite" some of the provided functions, be sure to add
## [code]super()[/code] at the end of the function definition so systems can
## be ran properly.
## [br][br]
## Once you're done making your menu, consult the documentation for [MenuManager]
## to integrate it into the system.

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
## [b]Internal-use only.[/b]
## The default process mode for a menu.
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
## [b]Internal-use only.[/b]
## Runs logic for when the close button is pressed.
func _on_close_button_pressed() -> void:
	close()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
