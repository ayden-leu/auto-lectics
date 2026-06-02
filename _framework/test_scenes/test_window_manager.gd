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
@onready var consoleStuff: VBoxContainer = %ConsoleStuff


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
	FR_MenuManager.disable()
	FR_WindowManager.enable()
	CursorHandler.setDefault("shown")
	CursorHandler.showNuclear()

	DebugHud.addChecklistEntry("Can create ExampleWindow")
	DebugHud.addChecklistEntry("ExampleWindow can be closed")

	DebugHud.addChecklistEntry("Can create DialogueConsole")
	DebugHud.addChecklistEntry("Can subscribe to DialogueConsole")
	DebugHud.addChecklistEntry("DialogueConsole help command displays help message")
	DebugHud.addChecklistEntry("DialogueConsole plays [userTextAdded] SFX event")
	DebugHud.addChecklistEntry("DialogueConsole plays [userTextSubmitted] SFX event")
	DebugHud.addChecklistEntry("DialogueConsole entered command gets displayed")
	DebugHud.addChecklistEntry("DialogueConsole clear command clears entries")
	DebugHud.addChecklistEntry("DialogueConsole hitting UP and DOWN key cycles through entered commands")
	DebugHud.addChecklistEntry("DialogueConsole creates DialogueWarningTileWindows during hectic mode")
	DebugHud.addChecklistEntry("DialogueConsole can be restricted from closing")
	DebugHud.addChecklistEntry("Trying to close DialogueConsole while closing is blocked displays a message")
	DebugHud.addChecklistEntry("DialogueConsole plays [closeReject] SFX event")
	DebugHud.addChecklistEntry("DialogueConsole can have messages pushed to it")
	DebugHud.addChecklistEntry("DialogueConsole pushed message can have write speed modified")
	DebugHud.addChecklistEntry("DialogueConsole pushed message can have theme modified")
	DebugHud.addChecklistEntry("DialogueConsole pushed message can be instant")
	DebugHud.addChecklistEntry("Can unsubscribe from DialogueConsole")
	DebugHud.addChecklistEntry("DialogueConsole exit command closes it")
	DebugHud.addChecklistEntry("DialogueConsole close button closes it")

	DebugHud.addChecklistEntry("BlueprintWindow can be opened")
	DebugHud.addChecklistEntry("Can subscribe to BlueprintWindow")
	DebugHud.addChecklistEntry("BlueprintWindow pages can be navigated")
	DebugHud.addChecklistEntry("BlueprintWindow entries can be clicked")
	DebugHud.addChecklistEntry("BlueprintWindow entry name can be updated")
	DebugHud.addChecklistEntry("BlueprintWindow correct entry name displays such")
	DebugHud.addChecklistEntry("BlueprintWindow test entries are Aster, Mira, Orin, and John")
	DebugHud.addChecklistEntry("BlueprintWindow test unlock condition of guessing Aster and Orin correctly works")
	DebugHud.addChecklistEntry("Can unsubscribe to BlueprintWindow")
	DebugHud.addChecklistEntry("BlueprintWindow and the windows it spawns can be closed")

	DebugHud.addChecklistEntry("Can kill all windows")

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
	await get_tree().process_frame

	var handler:SfxEventHandler = FR_WindowManager.dialogueConsole.sfxEventHandler
	if handler:
		if handler.sfxIds.has("closeReject"):
			handler.sfxIds.closeReject = "_test_1"
		if handler.sfxIds.has("userTextAdded"):
			handler.sfxIds.userTextAdded = "_test_2"
		if handler.sfxIds.has("userTextSubmitted"):
			handler.sfxIds.userTextSubmitted = "_test_3"
		if handler.sfxIds.has("close"):
			handler.sfxIds.close = "_test_3"
		AudioLoader.loadSfxIntoPlayers(handler.sfxIds, handler._sfxEventNameToPlayer)

	consoleStuff.show()

	FR_WindowManager.dialogueConsole.window_closed.connect(
		func(_console):
			consoleStuff.hide()
	)


func _on_create_console_option_pressed() -> void:
	FR_WindowManager.createDialogueOptionWindow()

func _on_kill_console_pressed() -> void:
	FR_WindowManager.killDialogueConsole()

	consoleStuff.hide()

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

func _on_create_warning_tile_window_pressed() -> void:
	FR_WindowManager.createDialogueWarningTileWindow()

func _on_console_can_close_toggle_toggled(toggled_on: bool) -> void:
	if not FR_WindowManager.dialogueConsole:
		return

	FR_WindowManager.dialogueConsole.canBeClosed = toggled_on

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
