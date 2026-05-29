@tool
extends Menu
## The menu that appears when the player pauses the game during gameplay.
##
## Comes with three buttons:[br]
## - To resume the game.[br]
## - To open the [BlueprintMenu] (deprecated and not usable).[br]
## - To open the Options menu.[br]
## - To close the game.[br]
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
## The [SfxEventHandler] for this menu.
@onready var _sfxEventHandler:SfxEventHandler = %SfxEventHandler

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	menuID = "pause"
	super()  # runs the inherited class' _ready() function.

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for resume button pressing.
func _on_resume_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	close()

## [b]Internal-use only.[/b]
## Handles logic for options button pressing.
func _on_options_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	FR_MenuManager.openMenu("options")

## @deprecated
## [b]Internal-use only.[/b]
## Handles logic for blueprint button pressing.
func _on_blueprint_button_pressed() -> void:
	return
	#sfxEventHandler.play("buttonPressed")
	#FR_MenuManager.openMenu("blueprint")

## [b]Internal-use only.[/b]
## Handles logic for quit button pressing.
func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
