@tool
extends NPC

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when [method respawn] runs.
signal respawned()

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
	super()  # runs the inherited class' _ready() function.

func _process(delta: float) -> void:
	super(delta)  # runs the inherited class' _process() function.

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Dummy respawn function for testing.
func respawn() -> void:
	DebugHud.addToLog("Test NPC:  Repsawn function ran.")
	respawned.emit()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Editor-use Only.[/b]
## Returns editor warnings depending on this thing's state.
func _get_configuration_warnings() -> PackedStringArray:
	return super()

## [b]Editor-use Only.[/b]
## Hides certain export fields depending on this thing's state.
func _validate_property(property:Dictionary) -> void:
	super(property)
