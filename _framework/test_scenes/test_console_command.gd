extends Node3D

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
@onready var barAnimPlayer:AnimationPlayer = $Bar/AnimationPlayer
@onready var player:Player = $Player

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
	FR_MenuManager.enable()
	FR_WindowManager.enable()
	CursorHandler.setDefault("hidden")
	CursorHandler.hideNuclear()
	FR_WindowManager.subscribeToConsole(self)

	DebugHud.addChecklistEntry("Console commands mentioned in the sky text work")

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

func _on_console_command_entered(command:String) -> void:
	if command == "spin_start":
		barAnimPlayer.play("spin")
	elif command == "spin_stop":
		barAnimPlayer.pause()
	elif command == "spin_reset":
		barAnimPlayer.play("RESET")
	elif command == "unfreeze":
		Player.unfreezeForce()
	elif command == "jump":
		player.jump()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
