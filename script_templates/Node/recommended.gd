# meta-default: true
# meta-name: Recommended Script Template
# meta-description: A template that provides pre-defined sections for various things you might define in this script.

extends _BASE_

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
#func _ready() -> void:
_TS_# super()  # needed if inheriting a custom class with its own _ready().  Will run the inherited class' _ready() function.

#func _process(delta: float) -> void:
_TS_#super(delta)  # needed if inheriting a custom class with its own _process().  Will run the inherited class' _process() function.

#func _physics_process(delta: float) -> void:
_TS_#super(delta)  # needed if inheriting a custom class with its own _physics_process().  Will run the inherited class' _physics_process() function.

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
