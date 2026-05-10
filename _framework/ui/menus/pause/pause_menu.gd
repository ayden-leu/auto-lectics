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
## [b]Internal-use only.[/b]  Handles logic for resume button pressing.
func _on_resume_pressed() -> void:
	close()

## [b]Internal-use only.[/b]  Handles logic for options button pressing.
func _on_options_pressed() -> void:
	FR_MenuManager.openMenu("options")

## [b]Internal-use only.[/b]  Handles logic for blueprint button pressing.
func _on_blueprint_button_pressed() -> void:
	FR_MenuManager.openMenu("blueprint")

## [b]Internal-use only.[/b]  Handles logic for quit button pressing.
func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
