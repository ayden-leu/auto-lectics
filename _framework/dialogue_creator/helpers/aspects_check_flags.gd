extends DC_AspectsFlags
class_name DC_AspectsCheckFlags
## [b]Internal-use only.[/b]  Check [DC_AspectsFlags] for functionality.

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
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_storyFlagScene = preload("uid://b7qu1lm6jcww2")
	super()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_add_button_pressed() -> void:
	super()

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_flag_field_removed(field:DC_StoryFlagFieldOption) -> void:
	super(field)

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_flag_field_updated(oldFlagID:String, newFlagID:String) -> void:
	super(oldFlagID, newFlagID)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
