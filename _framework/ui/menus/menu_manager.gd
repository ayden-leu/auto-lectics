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
## [b]Internal-use only.[/b]  A loaded resource copy of the blueprint menu.
const _BLUEPRINT_MENU = preload("uid://bult80lkyvnls")

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
## [b]Internal-use only.[/b]  Holds all created menus.
var _menus:Array[Menu] = []
## [b]Internal-use only.[/b]  Maps menu IDs to their index in [member _menus].
var _idToIndex:Dictionary[String, int] = {}
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
	
	_createMenu(_PAUSE_MENU)
	_createMenu(_OPTIONS_MENU)
	_createMenu(_KEYBINDS_MENU)
	_createMenu(_BLUEPRINT_MENU)

func _process(_delta:float) -> void:
	if not enabled:
		return
	
	if not menuIsOpen:
		if Input.is_action_just_pressed("open_pause_menu"):
			openMenu("pause")
		elif Input.is_action_just_pressed("open_blueprint"):
			openMenu("blueprint")
	elif Input.is_action_just_pressed("close_current_menu"):
		_on_menu_close()
		
		if _menuStack.is_empty():
			_resume()

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
	
	if not menuID in _idToIndex.keys():
		printerr("MenuManager:  Invalid menu ID: [" + menuID + "]")
		return
	
	if _currentMenu: _currentMenu.disable()
	var menuToOpen:Menu = _getMenu(menuID)
	
	if menuToOpen.pausesGame:
		get_tree().paused = true
	_menuStack.push_back(menuToOpen)
	menuToOpen.enable()
	menuIsOpen = true
	InputHandler.showCursorTemp()
	InputHandler.disableMovementInputGlobal()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Creates each menu scene.
func _createMenu(menu:Resource) -> void:
	var temp:Menu = menu.instantiate()
	add_child(temp)
	
	_idToIndex[temp.id] = _menus.size()
	_menus.push_back(temp)
	
	temp.close_me.connect(_on_menu_close)
	temp.disable()

## [b]Internal-use only.[/b]  Gets a menu scene based on their ID.
func _getMenu(menuIO:String) -> Menu:
	return _menus[_idToIndex[menuIO]]

func _resume() -> void:
	get_tree().paused = false
	menuIsOpen = false
	InputHandler.restoreCursorMode()
	InputHandler.enableMovementInputGlobal()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when a menu wants to be closed.
func _on_menu_close() -> void:
	var menuToClose:Menu = _menuStack.pop_back()
	menuToClose.disable()
	if _currentMenu != null:
		_currentMenu.enable()
	else:
		_resume()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
