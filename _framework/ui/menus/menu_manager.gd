extends Node
class_name MenuManager
## Manages any menus opened by the player.

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
## [b]Internal-use only.[/b]  A loaded resource copy of the pause menu.
const _PAUSE_MENU:Resource = preload("uid://bqesuy1fypg26")
## [b]Internal-use only.[/b]  A loaded resource copy of the options menu.
const _OPTIONS_MENU = preload("uid://duxwayninhwqb")
## [b]Internal-use only.[/b]  A loaded resource copy of the keybinds menu.
const _KEYBINDS_MENU = preload("uid://b08l8xg1t3ct6")


# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The darken overlay that gets shown when a menu is open.
@onready var _overlay:ColorRect = %Overlay

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## If the [MenuManager] can do stuff or not.
var enabled:bool = false:
	set(state):
		enabled = state
		if state:
			enable()
		else:
			disable()
## If a menu is open or not.
var menuIsOpen:bool = false:
	set(state):
		menuIsOpen = state
		_overlay.visible = state

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  The stack that keeps track of all open menus.
var _menuStack:Array[Menu] = []
## [b]Internal-use only.[/b]  The currently open menu.
## Is a shortcut accessor for the last entry in [member _menuStack].
var _currentMenu:Menu:
	set(_value):
		return
	get():
		if _menuStack.is_empty():
			return null
		return _menuStack.back()

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_overlay.z_index = FR_Globals.MENU_Z_INDEX - 1

func _process(_delta:float) -> void:
	if not enabled:
		return
	
	if Input.is_action_just_pressed("open_pause_menu") and not menuIsOpen:
		get_tree().paused = true
		openMenu("pause")
		menuIsOpen = true
	elif Input.is_action_just_pressed("close_current_menu"):
		_on_menu_close()

	if _menuStack.is_empty():
		get_tree().paused = false
		menuIsOpen = false

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Enables the [MenuManager].  Same thing as setting [member enabled] to true.
func enable() -> void:
	if not enabled:  enabled = true
	process_mode = Node.PROCESS_MODE_ALWAYS

## Disables the [MenuManager].  Same thing as setting [member enabled] to false.
func disable() -> void:
	if enabled:  enabled = false
	process_mode = Node.PROCESS_MODE_DISABLED

## Opens a menu based on the string ID given
func openMenu(menuID:String) -> void:
	if not enabled:
		printerr("MenuManager:  Cannot open menu due to not being enabled.")
		return
	
	if _currentMenu: _currentMenu.disable()
	
	match menuID:
		"pause":     _loadMenu(_PAUSE_MENU)
		"options":   _loadMenu(_OPTIONS_MENU)
		"keybinds":  _loadMenu(_KEYBINDS_MENU)
		_:
			printerr("MenuManager: Invalid menu ID: [", menuID, "]")
			if _currentMenu: _currentMenu.enable()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Loads a menu.
func _loadMenu(menu:Resource) -> void:
	var temp:Menu = menu.instantiate()
	_menuStack.push_back(temp)
	add_child(temp)
	temp.close_me.connect(_on_menu_close)
	temp.enable()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when a menu wants to be closed.
func _on_menu_close() -> void:
	var menuToClose:Menu = _menuStack.pop_back()
	menuToClose.delete()
	if _currentMenu != null:
		_currentMenu.enable()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
