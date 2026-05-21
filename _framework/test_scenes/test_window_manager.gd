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
func _ready() -> void:
	CursorHandler.showCursor()

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
func _on_create_example_window_pressed() -> void:
	FR_WindowManager.createExampleWindow()

func _on_create_console_pressed() -> void:
	FR_WindowManager.createDialogueConsole()

func _on_create_console_option_pressed() -> void:
	FR_WindowManager.createDialogueOptionWindow()

func _on_kill_console_pressed() -> void:
	FR_WindowManager.killDialogueConsole()

func _on_subscribe_to_console_pressed() -> void:
	FR_WindowManager.subscribeToConsole(self)

func _on_unsubscribe_to_console_pressed() -> void:
	FR_WindowManager.unsubscribeToConsole(self)

func _on_console_command_entered(command:String) -> void:
	%EnteredConsoleCommand.text = command

func _on_kill_all_windows_pressed() -> void:
	for _i in range(FR_WindowManager._spawnedWindows.size()):
		FR_WindowManager._spawnedWindows[0].close()

func _on_start_console_hectic_mode_pressed() -> void:
	if not FR_WindowManager.dialogueConsole:
		printerr("Dialogue Console hasn't been created.")
		return

	FR_WindowManager.dialogueConsole.mode = "hectic"
	FR_WindowManager.dialogueConsole.textToAdd = "Starting Hectic Mode"
	FR_WindowManager.dialogueConsole.start()

func _on_push_message_to_console_pressed() -> void:
	var meta:Dictionary = {}
	if %PassWriteSpeed.button_pressed:
		meta.writeSpeed = %MessageWriteSpeed.value
	if %PassTheme.button_pressed:
		meta.theme = %MessageTheme.text
	if %PassInstant.button_pressed:
		meta.instant = %MessageInstant.button_pressed

	FR_WindowManager.pushMessageToConsole(%MessageToConsole.text, meta)

func _on_create_blueprint_window_pressed() -> void:
	FR_WindowManager.createBlueprintWindow()

func _on_subscribe_to_blueprint_window_pressed() -> void:
	FR_WindowManager.subscribeToBlueprintWindow(self)

func _on_unsubscribe_to_blueprint_window_pressed() -> void:
	FR_WindowManager.unsubscribeToBlueprintWindow(self)

func _on_blueprint_npc_name_guessed_correctly(npcID:String) -> void:
	%BlueprintEntryGuessedCorrectlyID.text = npcID

func _on_blueprint_unlock_condition_met(conditionID:String) -> void:
	%BlueprintUnlockConditionMet.text = conditionID

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
