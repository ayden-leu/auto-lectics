@tool
extends Menu
## A menu that lets players customize game settings.
##
## Comes with three buttons:[br]
## - To open the Keybinds menu.[br]
## - To modify the screen size.[br]
## - To close this menu.[br]
## [br][br]
## The [member _applySettings] button is initially disabled and becomes enabled
## when any of the settings are modified.
## [br][br]
## [b]Configurable Settings[/b][br]
## There is currently only one setting:  Window Mode.
## Window Mode can be set to to the presets defined in [member _windowPresets].
## [br][br]
## Also plays a sound whenever a button is clicked via its [member _sfxEventHandler].

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
## [b]Internal-use only.[/b]
## Holds the window size modes that can be chosen and set.
@onready var _windowModeOptions:OptionButton = %WindowModeOptions
## [b]Internal-use only.[/b]
## The [SfxEventHandler] for this menu.
@onready var _sfxEventHandler:SfxEventHandler = %SfxEventHandler
## [b]Internal-use only.[/b]
## The button that applies all of the configured settings.
@onready var _applySettings: Button = %ApplySettings

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The modes the game window can be in.
var _windowPresets = [
	{"name": "Windowed",             "mode": DisplayServer.WINDOW_MODE_WINDOWED,   "flag": 0},
	{"name": "Borderless",           "mode": DisplayServer.WINDOW_MODE_WINDOWED,   "flag": DisplayServer.WINDOW_FLAG_BORDERLESS},
	{"name": "Maximized",            "mode": DisplayServer.WINDOW_MODE_MAXIMIZED,  "flag": 0},
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

	# loads the _windowPresets into _windowModeOptions
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
## [b]Internal-use only.[/b]
## Updates the window size mode.
func _updateWindowMode(newMode:String) -> void:
	_resetFlags()
	for preset in _windowPresets:
		if preset.name != newMode:
			continue

		DisplayServer.window_set_mode(preset.mode)
		if preset.flag != 0:
			DisplayServer.window_set_flag(preset.flag, true)
		return

## [b]Internal-use only.[/b]
## Resets all possible window flags that could have been set via [member _windowPresets].
func _resetFlags() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when the keybinds button is pressed.
func _on_keybinds_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	FR_MenuManager.openMenu("keybinds")

## [b]Internal-use only.[/b]
## Handles logic for when the back button is pressed.
func _on_back_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	close()

## [b]Internal-use only.[/b]
## Handles logic for when the [member _applySettings] button is pressed.
func _on_apply_settings_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	var selectedMode:String = _windowModeOptions.get_item_text(_windowModeOptions.selected)
	_updateWindowMode(selectedMode)
	_applySettings.disabled = true

## [b]Internal-use only.[/b]
## Handles logic for when an option from the [member _windowModeOptions] button is picked.
func _on_window_mode_options_item_selected(_index:int) -> void:
	_applySettings.disabled = false

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
