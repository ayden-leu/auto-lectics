@tool
extends InteractableNPC

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
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	super()  # runs the inherited class' _ready() function.

	if Engine.is_editor_hint():
		return

	FR_WindowManager.subscribeToConsole(self)

func _process(delta: float) -> void:
	super(delta)  # runs the inherited class' _process() function.

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
func _on_console_option_chosen(nextID:String) -> void:
	super(nextID)

	#if not isTalking:
		#print(internalID + " isn't talking.")
	#else:
		#print(internalID + " is talking.")

func _on_console_command_entered(command:String) -> void:
	if command == "yell":
		FR_WindowManager.pushMessageToConsole("AAAAAAAAAAAAAAAAAAAAAAA")

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
