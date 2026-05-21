@icon("uid://bfg0nlmruxfhi")
extends Node
class_name WindowManager

# NOTE:  how to handle cursor stuff
# make a cursor handler
#   this is cause Windows and Menus can affect cursor status,
#   so to make it less complicated just combine it into
#   one handler
# have array for cursor states when doing temp show/hide
#   kind of like how MenuManager does its stack for menus


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
## [b]Internal-use only.[/b]
## A reference to an example window.
const _EXAMPLE_WINDOW = preload("uid://cksoxvpnvcbjd")
## [b]Internal-use only.[/b]
## A reference to the [DialogueConsole] scene.
const _DIALOGUE_CONSOLE_SCENE:Resource = preload(FR_Globals.SCENES.DialogueConsoleWindow)
## [b]Internal-use only.[/b]
## A reference to the [DialogueConsoleOptionWindow] scene.
const _OPTION_WINDOW_SCENE:Resource = preload(FR_Globals.SCENES.DialogueConsoleOptionWindow)
## [b]Internal-use only.[/b]
## Contains reference to the warning tile scene where warnings will spawn
const _WARNING_WINDOW_SCENE: PackedScene = preload(FR_Globals.SCENES.DialogueWarningTileWindow)
## [b]Internal-use only.[/b]
## Contains reference to the blueprint window
const _BLUEPRINT_WINDOW_SCENE: Resource = preload(FR_Globals.SCENES.BlueprintWindow)
## [b]Internal-use only.[/b]
## Contains reference to the blueprint's npc details window
const _BLUEPRINT_DETAIL_WINDOW_SCENE: Resource = preload(FR_Globals.SCENES.BlueprintNpcDetailWindow)

## [b]Internal-use only.[/b]
## Maps subscriber method names to [DialogueConsole] signal names.
const _CONSOLE_SIGNAL_MAP:Dictionary = {
	"_on_console_option_chosen": "option_chosen",
	"_on_console_all_dialogue_text_visible": "all_dialogue_text_visible",
	"_on_console_new_option_available": "new_option_available",
	"_on_console_all_options_available": "all_options_available",
	"_on_console_command_entered": "command_entered",
	"_on_console_close": "window_closed"
}

## [b]Internal-use only.[/b]
## Maps subscriber method names to [BlueprintWindow] signal names.
const _BLUEPRINT_SIGNAL_MAP:Dictionary = {
	"_on_blueprint_npc_name_guessed_correctly": "npc_name_guessed_correctly",
	"_on_blueprint_unlock_condition_met": "unlock_condition_met"
}

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## A public reference to the [DialogueConsole].
## Useful if you want to listen to signals from it.
var dialogueConsole:DialogueConsole = null
## A public reference to the [BlueprintWindow].
## Useful if you want to listen to signals from it.
var blueprintWindow:BlueprintWindow = null
## A public reference to the [BlueprintNpcDetailsWindow].
## Useful if you want to listen to signals from it.
var blueprintDetailWindow: BlueprintNpcDetailWindow = null

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Holds all windows created by the manager.
var _spawnedWindows:Array[DialogueWindow] = []
## [b]Internal-use only.[/b]
## Holds all nodes that want to listen to [DialogueConsole]'s signals.
var _dialogueConsoleSubscribers:Array = []
## [b]Internal-use only.[/b]
## The screen position of the [DialogueConsole].
var dialogueConsoleLastPosition: Vector2 = Vector2.ZERO
## [b]Internal-use only.[/b]
## Holds all nodes that want to listen to [BlueprintWindow]'s signals.
var _blueprintWindowSubscribers:Array = []
## [b]Internal-use only.[/b]
## Stores blueprint data between closing and reopening the [BlueprintWindow].
var _blueprintSavedState: Dictionary = {}

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print(_getCenter(Vector2.ZERO))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_blueprint"):
		FR_WindowManager.createBlueprintWindow()
# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Creates an example [DialogueWindow].
func createExampleWindow() -> DialogueWindow:
	var tempWindow:DialogueWindow = _EXAMPLE_WINDOW.instantiate()
	_addWindow(tempWindow)
	return tempWindow

## Creates a [DialogueConsole].  Only one can exist at a time.  Not pre-configured.
func createDialogueConsole() -> DialogueConsole:
	if dialogueConsole != null:
		return dialogueConsole

	dialogueConsole = _DIALOGUE_CONSOLE_SCENE.instantiate()
	_addWindow(dialogueConsole)

	if dialogueConsoleLastPosition != Vector2.ZERO:
		dialogueConsole.position = dialogueConsoleLastPosition
	dialogueConsole.global_position = _getCenter(dialogueConsole.size)

	_dialogueConsoleSubscribers = _cleanSubscriberList(_dialogueConsoleSubscribers)
	_resubscribeList(_dialogueConsoleSubscribers, _connectConsoleSignalsToSubscriber)

	return dialogueConsole

## Kills the current [DialogueConsole].
func killDialogueConsole() -> void:
	if dialogueConsole != null:
		dialogueConsoleLastPosition = dialogueConsole.position
		dialogueConsole.kill()
		_on_window_closed(dialogueConsole)
		dialogueConsole = null

## Creates a [DialogueConsoleOptionWindow].  Not pre-configured.
func createDialogueOptionWindow() -> DialogueConsoleOptionWindow:
	var optionWindow:DialogueConsoleOptionWindow = _OPTION_WINDOW_SCENE.instantiate()
	_addWindow(optionWindow)
	return optionWindow

## Creates a [DialogueWarningTileWindow], while avoiding the main console
func createDialogueWarningTileWindow() -> DialogueWarningTileWindow:
	var warningWindow:DialogueWarningTileWindow = _WARNING_WINDOW_SCENE.instantiate()
	_addWindow(warningWindow)
	return warningWindow

## [b]Internal-use only.[/b]  Closes all [DialogueWarningTileWindow] windows.
func closeAllWarningTileWindows() -> void:
	var tempStorage:Array[DialogueWarningTileWindow] = []
	for window in _spawnedWindows:
		if window is DialogueWarningTileWindow:
			tempStorage.push_back(window)

	for windowToDelete in tempStorage:
		windowToDelete.close()


## [b]Internal-use only.[/b] Creates a blueprint window
func createBlueprintWindow() -> BlueprintWindow:
	if blueprintWindow != null:
		return blueprintWindow
	InputHandler.showCursorTemp()
	Player.disableInput(true)

	blueprintWindow = _BLUEPRINT_WINDOW_SCENE.instantiate()
	_addWindow(blueprintWindow)

	if not blueprintWindow.window_closed.is_connected(_on_blueprint_window_closed):
		blueprintWindow.window_closed.connect(_on_blueprint_window_closed)
	blueprintWindow.global_position = _getRightSidePosition(blueprintWindow.size)
	if not _blueprintSavedState.is_empty(): # apply the saved state of NPC info
		blueprintWindow.apply_state(_blueprintSavedState)

	_blueprintWindowSubscribers = _cleanSubscriberList(_blueprintWindowSubscribers)
	_resubscribeList(_blueprintWindowSubscribers, _connectBlueprintSignalsToSubscriber)
	return blueprintWindow

## [b]Internal-use only.[/b] Creates blueprint NPC detail window when clicking on NPCs in blueprint
func createBlueprintNpcDetailWindow() -> BlueprintNpcDetailWindow:
	if blueprintDetailWindow != null:
		return blueprintDetailWindow

	blueprintDetailWindow = _BLUEPRINT_DETAIL_WINDOW_SCENE.instantiate()
	blueprintDetailWindow.process_mode = Node.PROCESS_MODE_ALWAYS
	blueprintDetailWindow.z_index = 3
	_addWindow(blueprintDetailWindow)

	if not blueprintDetailWindow.window_closed.is_connected(_on_blueprint_detail_window_closed):
		blueprintDetailWindow.window_closed.connect(_on_blueprint_detail_window_closed)

	blueprintDetailWindow.global_position = _getLeftSidePosition(blueprintDetailWindow.size)
	return blueprintDetailWindow

## Closes the blueprint window
func closeBlueprintWindow() -> void:
	if blueprintWindow != null:
		blueprintWindow.close()

## Closes the blueprint NPC detail window
func closeBlueprintNpcDetailWindow() -> void:
	if blueprintDetailWindow != null:
		blueprintDetailWindow.close()

## Connects signals from the [DialogueConsole] to specific functions the subscriber
## can define.  Also adds the subscriber to a list so the signals can be reconnected
## when the [DialogueConsole] gets created again.
## [br][br]
## Here is a list functions that you must define in order to run code
## whenever the associated signal is emitted.
## [codeblock]
## func _on_console_option_chosen(nextID:String) -> void:
## 	# Associated signal: option_chosen
## 	# Will run whenever an option spawned by the DialogueConsole is picked.
## 	# nextID is the ID of the dialogue file to be loaded.
##
## func _on_console_all_dialogue_text_visible() -> void:
## 	# Associated signal:  all_dialogue_text_visible
## 	# Will run whenever the dialogue text being written by the console is fully visible.
##
## func _on_console_new_option_available() -> void:
## 	# Associated signal:  new_option_available
## 	# Will run whenever a new option is spawned by the DialogueConsole.
##
## func _on_console_all_options_available() -> void:
## 	# Associated signal:  all_options_available
## 	# Will run whenever all options the DialogueConsole wants to spawn, are spawned.
##
## func _on_console_command_entered(command:String) -> void:
## 	# Associated signal:  command_entered
## 	# Will run whenever the player enters a command into the console.
##
## func _on_console_close(console:DialogueConsole) -> void
## 	# Associated signal:  window_closed
## 	# Will run when the DialogueConsole is closed.
## [/codeblock]
func subscribeToConsole(subscriber) -> void:
	_addSubscriber(subscriber, _dialogueConsoleSubscribers, _connectConsoleSignalsToSubscriber)

## Unsubscribes a node from the [DialogueConsole], meaning it won't run any
## functions when the [DialogueConsole] emits signals.
func unsubscribeToConsole(subscriber) -> void:
	_removeSubscriber(subscriber, _dialogueConsoleSubscribers, _disconnectConsoleSignalsToSubscriber)

## Connects signals from the [BlueprintWindow] to specific functions the subscriber
## can define.  Also adds the subscriber to a list so the signals can be reconnected
## when the [BlueprintWindow] gets created again.
## [br][br]
## Here is a list functions that you must define in order to run code
## whenever the associated signal is emitted.
## [codeblock]
## func _on_blueprint_npc_name_guessed_correctly(npcID:String) -> void:
## 	# Associated signal: npc_name_guessed_correctly
## 	# Will run whenever the player guesses the name of an NPC entry correctly.
## 	# npcID is the ID of the NPC entry.
##
## func _on_blueprint_unlock_condition_met(conditionID:String) -> void:
## 	# Associated signal:  unlock_condition_met
## 	# Will run whenever an unlock condition is met.
## 	# conditionID is the ID of the unlock condition.
## [/codeblock]
func subscribeToBlueprintWindow(subscriber) -> void:
	_addSubscriber(subscriber, _blueprintWindowSubscribers, _connectBlueprintSignalsToSubscriber)

## Unsubscribes a node from the [BlueprintWindow], meaning it won't run any
## functions when the [BlueprintWindow] emits signals.
func unsubscribeToBlueprintWindow(subscriber) -> void:
	_removeSubscriber(subscriber, _blueprintWindowSubscribers, _disconnectBlueprintSignalsToSubscriber)

## Pushes a text entry to the [DialogueConsole].
## [br][br]
## [code]metadata[/code] can have the following fields:
## [codeblock]
## 	"writeSpeed":  # a float for the number of characters per second to display.
## 	"instant":  # if the text should be displayed instantly.
## 	"theme":  # the text theme to apply to this entry.
## [/codeblock]
func pushMessageToConsole(message:String, metadata:Dictionary = {}) -> void:
	if not dialogueConsole:
		return

	dialogueConsole.addExternalEntry(message, metadata)

## Checks if a position is within the screen.
## [code]threshold[/code] is the amount, in pixels, beyond the screen the position can be.
func positionOnScreen(pos:Vector2, threshold:float = 0) -> bool:
	var screen_rect := get_viewport().get_visible_rect()

	var min_x := -threshold
	var min_y := -threshold
	var max_x := screen_rect.size.x + threshold
	var max_y := screen_rect.size.y + threshold

	return pos.x >= min_x and pos.x <= max_x and pos.y >= min_y and pos.y <= max_y

## Gets a random position on screen.
## [br][br]
## [code]window_size[/code] is the size of the window to consider.
## [br][br]
## [code]allowOverlap[/code] is a list of window types that this position can overlap.
## The type of a window is defined by [member DialogueWindow.windowType]
func getRandomPositionOnScreen(window_size: Vector2, allowOverlap:Array[String] = []) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	var margin := 20.0
	var retryAttempts:int = 30

	for attempt in range(retryAttempts):
		var pos := Vector2(
			randf_range(margin, viewport_size.x - window_size.x - margin),
			randf_range(margin, viewport_size.y - window_size.y - margin)
		)

		var overlapping:bool = false
		for window in _spawnedWindows:
			if window.windowType in allowOverlap:
				continue

			if window.get_global_rect().intersects(Rect2(pos, window_size)):
				overlapping = true
				break

		if not overlapping:
			return pos

	# fallback if all attempts fail
	return Vector2(margin, margin)

# TODO:  check if needed
## [b]Internal-use only.[/b]
## Updates the player's cursor/input state based on whether any windows are open.
func updateCursorStateForWindows() -> void:
	print(_spawnedWindows.size())
	if _spawnedWindows.size() > 0:
		InputHandler.showCursorTemp()
		Player.disableInput(true)
	else:
		InputHandler.restoreCursorMode()
		Player.disableInput(false)

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Finishes creating a window.
func _addWindow(window:DialogueWindow) -> void:
	add_child(window)
	_spawnedWindows.push_back(window)
	window.window_closed.connect(_on_window_closed)
	window.window_dropped.connect(_on_window_dropped)

	_setWindowOnScreen(window, window.offscreenThresold)

## [b]Internal-use only.[/b]
## Adds a node to a subscriber list and connects it to the relevant window.
func _addSubscriber(subscriber, subscriberList:Array, connectCallable:Callable) -> void:
	if subscriber in subscriberList:
		return

	subscriberList.push_back(subscriber)
	connectCallable.call(subscriber)

## [b]Internal-use only.[/b]
## Removes a node from a subscriber list and disconnects it from the relevant window.
func _removeSubscriber(subscriber, subscriberList:Array, disconnectCallable:Callable) -> void:
	if not subscriber in subscriberList:
		return

	var subscriberIndex:int = subscriberList.find(subscriber)
	subscriberList[subscriberIndex] = null
	disconnectCallable.call(subscriber)

## [b]Internal-use only.[/b]
## Removes all [code]null[/code] entries in the given subscriber list.
func _cleanSubscriberList(subscriberList:Array) -> Array:
	var newList:Array = []
	for subscriber in subscriberList:
		if subscriber == null:
			continue
		newList.push_back(subscriber)

	return newList

## [b]Internal-use only.[/b]
## Resubscribes all subscribers in the given subscriber list.
func _resubscribeList(subscriberList:Array, connectCallable:Callable) -> void:
	for subscriber in subscriberList:
		connectCallable.call(subscriber)

## [b]Internal-use only.[/b]
## Connects signals from a given window to functions defined by the subscriber.
func _connectSignalsFromMap(window:Node, subscriber, signalMap:Dictionary) -> void:
	if not window:
		return
	for methodName in signalMap.keys():
		if not subscriber.has_method(methodName):
			continue

		var signalName:String = signalMap[methodName]
		var callable:Callable = Callable(subscriber, methodName)
		var signalRef:Signal = Signal(window, signalName)

		if not signalRef.is_connected(callable):
			signalRef.connect(callable)

## [b]Internal-use only.[/b]
## Disconnects signals from a given window to functions defined by the subscriber.
func _disconnectSignalsFromMap(window:Node, subscriber, signalMap:Dictionary) -> void:
	if not window:
		return
	for methodName in signalMap.keys():
		if not subscriber.has_method(methodName):
			continue

		var signalName:String = signalMap[methodName]
		var callable:Callable = Callable(subscriber, methodName)
		var signalRef:Signal = Signal(window, signalName)

		if signalRef.is_connected(callable):
			signalRef.disconnect(callable)

## [b]Internal-use only.[/b]
## Connects the [DialogueConsole] signals to functions defined by the subscriber.
func _connectConsoleSignalsToSubscriber(subscriber) -> void:
	_connectSignalsFromMap(dialogueConsole, subscriber, _CONSOLE_SIGNAL_MAP)

## [b]Internal-use only.[/b]
## Disconnects the [DialogueConsole] signals from functions defined by the subscriber.
func _disconnectConsoleSignalsToSubscriber(subscriber) -> void:
	_disconnectSignalsFromMap(dialogueConsole, subscriber, _CONSOLE_SIGNAL_MAP)

## [b]Internal-use only.[/b]
## Connects the [BlueprintWindow] signals to functions defined by the subscriber.
func _connectBlueprintSignalsToSubscriber(subscriber) -> void:
	_connectSignalsFromMap(blueprintWindow, subscriber, _BLUEPRINT_SIGNAL_MAP)

## [b]Internal-use only.[/b]
## Disconnects the [BlueprintWindow] signals from functions defined by the subscriber.
func _disconnectBlueprintSignalsToSubscriber(subscriber) -> void:
	_disconnectSignalsFromMap(blueprintWindow, subscriber, _BLUEPRINT_SIGNAL_MAP)

## [b]Internal-use only.[/b]
## Moves the window back onto the screen if it's outside
func _setWindowOnScreen(window:DialogueWindow, threshold:float = 0) -> void:
	var screen_rect := get_viewport().get_visible_rect()
	var window_size := window.size

	var min_x := -threshold
	var min_y := -threshold
	var max_x := screen_rect.size.x - window_size.x + threshold
	var max_y := screen_rect.size.y - window_size.y + threshold

	window.global_position.x = clamp(window.global_position.x, min_x, max_x)
	window.global_position.y = clamp(window.global_position.y, min_y, max_y)

## [b]Internal-use only.[/b]
## Moves this window to the center of the screen immediately.
func _centerWindow(window:DialogueWindow) -> void:
	window.global_position = (get_viewport().get_visible_rect().size - window.size) / 2

## [b]Internal-use only.[/b]
## Get the center of the screen.
func _getCenter(windowSize:Vector2) -> Vector2:
	return (get_viewport().get_visible_rect().size - windowSize) / 2

## [b]Internal-use only.[/b]
## Gets a position for a window on the left side of the screen.
func _getLeftSidePosition(windowSize: Vector2, margin: float = 180.0) -> Vector2:
	var screenSize: Vector2 = get_viewport().get_visible_rect().size
	return Vector2(margin,(screenSize.y - windowSize.y) / 3)

## [b]Internal-use only.[/b]
## Gets a position for a window on the right side of the screen.
func _getRightSidePosition(windowSize: Vector2, margin: float = 180.0) -> Vector2:
	var screenSize: Vector2 = get_viewport().get_visible_rect().size
	return Vector2(screenSize.x - windowSize.x - margin,(screenSize.y - windowSize.y) / 3)
# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when a window is closed.
func _on_window_closed(closedWindow:DialogueWindow) -> void:
	if closedWindow in _spawnedWindows:
		_spawnedWindows.erase(closedWindow)
	updateCursorStateForWindows()

## [b]Internal-use only.[/b]
func _on_window_dropped(droppedWindow:DialogueWindow) -> void:
	var cornerPositions:Dictionary[String, Vector2] = droppedWindow.getGlobalCornerPositions()
	for cornerPosition:Vector2 in cornerPositions.values():
		if not positionOnScreen(cornerPosition, droppedWindow.offscreenThresold):
			_setWindowOnScreen(droppedWindow, droppedWindow.offscreenThresold)
			break

## [b]Internal-use only.[/b]  Handles logic for when the blueprint window is closed.
func _on_blueprint_window_closed(window: DialogueWindow) -> void:
	if window == blueprintWindow:
		if blueprintWindow != null:
			# save the state of the blueprint window (ie. NPC names and notes)
			_blueprintSavedState = blueprintWindow.get_state()
		blueprintWindow = null
	_on_window_closed(window)

## [b]Internal-use only.[/b]  Handles logic for when the blueprint NPC Details window is closed.
func _on_blueprint_detail_window_closed(window: DialogueWindow) -> void:
	if window == blueprintDetailWindow:
		blueprintDetailWindow = null

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
