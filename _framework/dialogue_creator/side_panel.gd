extends Control

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
## [b]Internal-use only.[b]  The initial position of the side panel.
var _defaultPosition:Vector2
## [b]Internal-use only.[b]  If the side panel is expanded or not.
var expanded:bool = false:
	set(state):
		expanded = state
		if state:
			_expand()
		else:
			_contract()

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_defaultPosition = global_position

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _expand() -> void:
	global_position = _defaultPosition + Vector2(397, 0)

func _contract() -> void:
	global_position = _defaultPosition

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------


func _on_toggler_pressed() -> void:
	expanded = !expanded
