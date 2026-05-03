extends Control

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
func _on_create_console_pressed() -> void:
	FR_WindowManager.createDialogueConsole()

func _on_create_console_option_pressed() -> void:
	FR_WindowManager.createDialogueOptionWindow()

func _on_kill_console_pressed() -> void:
	FR_WindowManager.closeDialogueConsole()

func _on_subscribe_to_console_pressed() -> void:
	FR_WindowManager.subscribeToConsole(self)

func _on_unsubscribe_to_console_pressed() -> void:
	FR_WindowManager.unsubscribeToConsole(self)

func _on_console_command_entered(command:String) -> void:
	%EnteredConsoleCommand.text = command

func _on_kill_all_windows_pressed() -> void:
	for _i in range(FR_WindowManager._spawnedWindows.size()):
		FR_WindowManager._spawnedWindows[0].close()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
