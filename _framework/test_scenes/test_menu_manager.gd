extends Node
## Test scene for [MenuManager]
##
## Lets user test [MenuManager]'s functionalities in an isolated environment.

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
@onready var _bpCorrectGuess: Label = %BP_CorrectGuess
@onready var _bpUnlockMet: Label = %BP_UnlockMet

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
	FR_WindowManager.disable()
	CursorHandler.setDefault("shown")
	CursorHandler.showNuclear()

	#FR_MenuManager.subscribeToBlueprintMenu(self)
	call_deferred("_continueReady")

	DebugHud.addChecklistEntry("Open Pause Menu via keybind")
	DebugHud.addChecklistEntry("Open Options Menu via button from Pause Menu")
	DebugHud.addChecklistEntry("Pause Menu button plays _test_1 sfx")
	DebugHud.addChecklistEntry("Open Keybinds Menu via button from Options Menu")
	DebugHud.addChecklistEntry("Options Menu button plays _test_2 sfx")

	DebugHud.addChecklistEntry("Keybinds Menu can be closed with keybind")
	DebugHud.addChecklistEntry("Options Menu can be closed with keybind")
	DebugHud.addChecklistEntry("Pause Menu can be closed with keybind")

	DebugHud.addChecklistEntry("Pause Menu resume button closes the menu")

	DebugHud.addChecklistEntry("Options Menu selecting a window mode enables Apply Settings button")
	DebugHud.addChecklistEntry("Options Menu Apply Settings button updates window mode")
	DebugHud.addChecklistEntry("Options Menu can set window mode to Windowed")
	DebugHud.addChecklistEntry("Options Menu can set window mode to Borderless")
	DebugHud.addChecklistEntry("Options Menu can set window mode to Maximized")
	DebugHud.addChecklistEntry("Options Menu can set window mode to Fullscreen")
	DebugHud.addChecklistEntry("Options Menu can set window mode to Exclusive Fullscreen")

	DebugHud.addChecklistEntry("Keybinds Menu shows all keybinds aside from ones in blacklist")

	DebugHud.addChecklistEntry("Keybinds Menu can be closed with back button")
	DebugHud.addChecklistEntry("Keybinds Menu button plays _test_3 sfx")
	DebugHud.addChecklistEntry("Options Menu can be closed with back button")
	DebugHud.addChecklistEntry("Pause Menu exit button closes the game")

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Hack-y hardcoded setup stuff purely for testing
func _continueReady() -> void:
	# menu order:
	# pause, options, keybinds
	var listOfMenus:Array[Menu] = FR_MenuManager._menus

	# pause
	var handler:SfxEventHandler = listOfMenus[0].get("_sfxEventHandler")
	if handler:
		if handler.sfxIds.has("buttonPressed"):
			handler.sfxIds.buttonPressed = "_test_1"
	AudioLoader.loadSfxIntoPlayers(handler.sfxIds, handler._sfxEventNameToPlayer)

	# options
	handler = listOfMenus[1].get("_sfxEventHandler")
	if handler:
		if handler.sfxIds.has("buttonPressed"):
			handler.sfxIds.buttonPressed = "_test_2"
	AudioLoader.loadSfxIntoPlayers(handler.sfxIds, handler._sfxEventNameToPlayer)

	# keybinds
	handler = listOfMenus[2].get("_sfxEventHandler")
	if handler:
		if handler.sfxIds.has("buttonPressed"):
			handler.sfxIds.buttonPressed = "_test_3"
	AudioLoader.loadSfxIntoPlayers(handler.sfxIds, handler._sfxEventNameToPlayer)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_blueprint_npc_name_guessed_correctly(npcID:String) -> void:
	_bpCorrectGuess.text = npcID

func _on_blueprint_unlock_condition_met(conditionID:String) -> void:
	_bpUnlockMet.text = conditionID

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
