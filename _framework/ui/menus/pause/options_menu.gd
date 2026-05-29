@tool
extends Menu

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

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  Holds thee window size modes that can be set.
@onready var _windowModeOptions:OptionButton = %WindowModeOptions
## [b]Internal-use only.[/b]
## The [SfxEventHandler] for this menu.
@onready var _sfxEventHandler:SfxEventHandler = %SfxEventHandler

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

var _windowPresets = [
	{"name": "Windowed",             "mode": DisplayServer.WINDOW_MODE_WINDOWED,   "flag": 0},
	{"name": "Fullscreen",           "mode": DisplayServer.WINDOW_MODE_FULLSCREEN, "flag": 0},
	{"name": "Exclusive Fullscreen", "mode": DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, "flag": 0}
]

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	menuID = "options"
	super()  # runs the inherited class' _ready() function.

	var i:int = 0
	for preset in _windowPresets:
		_windowModeOptions.add_item(preset.name)
		if preset.mode == DisplayServer.window_get_mode():
			_windowModeOptions.select(i)
		i += 1

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Updates the window size mode.
func _updateWindowMode(newMode:String) -> void:
	for preset in _windowPresets:
		if preset.name != newMode:
			continue

		DisplayServer.window_set_mode(preset.mode)
		if preset.flag != 0:
			DisplayServer.window_set_flag(preset.flag, true)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

#func _on_open_submenu_pressed() -> void:
#_TS_open.emit(subMenu)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when the keybinds button is pressed.
func _on_keybinds_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	FR_MenuManager.openMenu("keybinds")

## [b]Internal-use only.[/b]  Handles logic for when the back button is pressed.
func _on_back_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	close()

## [b]Internal-use only.[/b]  Handles logic for when the apply settings button is pressed.
func _on_apply_settings_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	var selectedMode:String = _windowModeOptions.get_item_text(_windowModeOptions.selected)
	_updateWindowMode(selectedMode)
