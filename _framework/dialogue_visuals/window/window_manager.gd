@icon("uid://bfg0nlmruxfhi")
extends Node
class_name WindowManager
## A helper class that createss and manages all [DialogueWindow] types.
##
## All nodes that inherit [DialogueWindow] are created and managed by this.
## [br][br]
## To create a window, run [code]create<window-type>()[/code].  The return value will
## be the newly created window.
## [br][br]
## To kill a "unique" window, run [code]kill<window-type>()[/code].
## [br][br]
## To subscribe to a window's signals (if they have them), run [code]subscribeTo<window-type>()[/code].
## This will make it so the node is still connected to the window's signals after its closed and reopened.
## [br][br]
## To unsubscribe to a window's signals (if they have them), run [code]unsubscribeTo<window-type>()[/code].
## This will reverse the process of subscribing to it.
## [br][br]
## [b]Current Window Types[/b][br]
## - ExampleWindow (this doesn't do anything)[br]
## - DialogueConsole[br]
## - DialogueConsoleOptionWindow[br]
## - DialogueWarningTileWindow[br]
## - BlueprintWindow[br]
## - BlueprintNpcDetailWindow[br]
## [br]
## [b]Current "Unique" Window Types[/b][br]
## - DialogueConsole[br]
## - BlueprintWindow[br]
## - BlueprintNpcDetailWindow[br]
## [br]
## [b]Current Windows Types With Signals[/b][br]
## - Console (this is just DialogueConsole)[br]
## - BlueprintWindow[br]

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
const _DIALOGUE_CONSOLE_SCENE:Resource = preload("uid://b8oqtsvu488a")
## [b]Internal-use only.[/b]
## A reference to the [DialogueConsoleOptionWindow] scene.
const _OPTION_WINDOW_SCENE:Resource = preload("uid://4opwac4ndc2k")
## [b]Internal-use only.[/b]
## A reference to the [DialogueWarnringTileWindow] scene.
const _WARNING_WINDOW_SCENE:PackedScene = preload("uid://dpeqr6fpd34gm")
## [b]Internal-use only.[/b]
## A reference to the [BlueprintWindow] scene.
const _BLUEPRINT_WINDOW_SCENE:Resource = preload("uid://ovwd5xcohsao")
## [b]Internal-use only.[/b]
## A reference to the [BlueprintNpcDetailWindow] scene.
const _BLUEPRINT_DETAIL_WINDOW_SCENE:Resource = preload("uid://524kk63lga7")

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
## Please do not modify the value of this directly.
var dialogueConsole:DialogueConsole = null
## A public reference to the [BlueprintWindow].
## Please do not modify the value of this directly.
var blueprintWindow:BlueprintWindow = null
## A public reference to the [BlueprintNpcDetailsWindow].
## Please do not modify the value of this directly.
var blueprintDetailWindow:BlueprintNpcDetailWindow = null

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Whether this does stuff or not.
var enabled:bool = true
## [b]Internal-use only.[/b]
## Whether inputs from the player should be registered or not.
var keybindsEnabled:bool = true
## [b]Internal-use only.[/b]
## Holds all windows created by the manager.
var _spawnedWindows:Array[DialogueWindow] = []
## [b]Internal-use only.[/b]
## The last known position of certain [DialogueWindow]s before they were closed.
## Each key corresponds to a [member DialogueWindow.windowType].
## Due to not being able to set a [Vector2] to [code]null[/code],
## [code]Vector2(-1000,-1000)[/code] will represent it.
var _prevWindowPosition:Dictionary[String, Vector2] = {
	"console": Vector2(-1000,-1000),
	"blueprint": Vector2(-1000,-1000),
	"blueprint_detail": Vector2(-1000,-1000)
}
## [b]Internal-use only.[/b]
## Holds all nodes that want to listen to [DialogueConsole]'s signals.
var _dialogueConsoleSubscribers:Array = []
## [b]Internal-use only.[/b]
## Holds all nodes that want to listen to [BlueprintWindow]'s signals.
var _blueprintWindowSubscribers:Array = []
## [b]Internal-use only.[/b]
## Stores [BlueprintWindow] data between closing and reopening the [BlueprintWindow].
var _blueprintSavedState:Dictionary = {}

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _input(event:InputEvent) -> void:
	if not enabled or not keybindsEnabled:
		return

	if event.is_action_pressed("open_blueprint"):
		createBlueprintWindow()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Enables the WindowManager.
func enable() -> void:
	enabled = true

## Disables the WindowManager.
func disable() -> void:
	enabled = false

## Enables the reading of player inputs.
func enableKeybinds() -> void:
	keybindsEnabled = true

## Disables the reading of player inputs.
func disableKeybinds() -> void:
	keybindsEnabled = false

## Creates an example [DialogueWindow].
func createExampleWindow() -> DialogueWindow:
	if not enabled:
		return

	var tempWindow:DialogueWindow = _EXAMPLE_WINDOW.instantiate()
	_addWindow(tempWindow)
	return tempWindow

## Creates a [DialogueConsole].  Only one can exist at a time.  Not pre-configured.
func createDialogueConsole() -> DialogueConsole:
	if not enabled:
		return null

	if dialogueConsole != null:
		return dialogueConsole

	dialogueConsole = _DIALOGUE_CONSOLE_SCENE.instantiate()
	_addWindow(dialogueConsole)
	dialogueConsole.window_closed.connect(_on_dialogue_console_closed)
	Player.freeze(dialogueConsole)

	if _prevWindowPosition[dialogueConsole.windowType] != Vector2(-1000,-1000):
		dialogueConsole.global_position = _prevWindowPosition[dialogueConsole.windowType]
	else:
		dialogueConsole.global_position = _getCenter(dialogueConsole.size)

	_dialogueConsoleSubscribers = _cleanSubscriberList(_dialogueConsoleSubscribers)
	_resubscribeList(_dialogueConsoleSubscribers, _connectConsoleSignalsToSubscriber)

	return dialogueConsole

## Kills the current [DialogueConsole].
func killDialogueConsole() -> void:
	if not enabled:
		return

	if dialogueConsole != null:
		_prevWindowPosition[dialogueConsole.windowType] = dialogueConsole.global_position
		Player.unfreeze(dialogueConsole)
		dialogueConsole.kill()
		_on_window_closed(dialogueConsole)
		dialogueConsole = null

## Creates a [DialogueConsoleOptionWindow].  Not pre-configured.
func createDialogueOptionWindow() -> DialogueConsoleOptionWindow:
	if not enabled:
		return null

	var optionWindow:DialogueConsoleOptionWindow = _OPTION_WINDOW_SCENE.instantiate()
	_addWindow(optionWindow)
	return optionWindow

## Creates a [DialogueWarningTileWindow], while avoiding the main console
func createDialogueWarningTileWindow() -> DialogueWarningTileWindow:
	if not enabled:
		return null

	var warningWindow:DialogueWarningTileWindow = _WARNING_WINDOW_SCENE.instantiate()
	_addWindow(warningWindow)
	return warningWindow

## Closes all [DialogueWarningTileWindow] windows.
func closeAllWarningTileWindows() -> void:
	if not enabled:
		return

	var tempStorage:Array[DialogueWarningTileWindow] = []
	for window in _spawnedWindows:
		if window is DialogueWarningTileWindow:
			tempStorage.push_back(window)

	for windowToDelete in tempStorage:
		windowToDelete.close()

## Creates a [BlueprintWindow] and restores its previous state ([member _blueprintSavedStat]) if it had one.
## Only only can exist at a time.
func createBlueprintWindow() -> BlueprintWindow:
	if not enabled:
		return null

	if blueprintWindow != null:
		return blueprintWindow

	blueprintWindow = _BLUEPRINT_WINDOW_SCENE.instantiate()
	_addWindow(blueprintWindow)

	blueprintWindow.window_closed.connect(_on_blueprint_window_closed)
	if not _blueprintSavedState.is_empty(): # apply the saved state of NPC info
		blueprintWindow.loadState(_blueprintSavedState)

	if _prevWindowPosition[blueprintWindow.windowType] != Vector2(-1000,-1000):
		blueprintWindow.global_position = _prevWindowPosition[blueprintWindow.windowType]
	else:
		blueprintWindow.global_position = _getRightSidePosition(blueprintWindow.size)

	_blueprintWindowSubscribers = _cleanSubscriberList(_blueprintWindowSubscribers)
	_resubscribeList(_blueprintWindowSubscribers, _connectBlueprintSignalsToSubscriber)
	return blueprintWindow

## Kills the current [member blueprintWindow].
func killBlueprintWindow() -> void:
	if not enabled:
		return

	if blueprintWindow != null:
		_prevWindowPosition[blueprintWindow.windowType] = blueprintWindow.global_position
		_blueprintSavedState = blueprintWindow.getState()
		blueprintWindow.kill()
		_on_window_closed(blueprintWindow)
		blueprintWindow = null

## Creates a [BlueprintNpcDetailWindow].  Only one can exist at a time.
func createBlueprintNpcDetailWindow() -> BlueprintNpcDetailWindow:
	if not enabled:
		return null

	if blueprintDetailWindow != null:
		return blueprintDetailWindow

	blueprintDetailWindow = _BLUEPRINT_DETAIL_WINDOW_SCENE.instantiate()
	_addWindow(blueprintDetailWindow)

	if not blueprintDetailWindow.window_closed.is_connected(_on_blueprint_detail_window_closed):
		blueprintDetailWindow.window_closed.connect(_on_blueprint_detail_window_closed)

	if _prevWindowPosition[blueprintDetailWindow.windowType] != Vector2(-1000,-1000):
		blueprintDetailWindow.global_position = _prevWindowPosition[blueprintDetailWindow.windowType]
	else:
		blueprintDetailWindow.global_position = _getLeftSidePosition(blueprintDetailWindow.size)

	return blueprintDetailWindow

## Kills the current [member blueprintDetailWindow].
func killBlueprintNpcDetailWindow() -> void:
	if not enabled:
		return

	if blueprintDetailWindow != null:
		_prevWindowPosition[blueprintDetailWindow.windowType] = blueprintDetailWindow.global_position
		blueprintDetailWindow.kill()
		_on_window_closed(blueprintDetailWindow)
		blueprintDetailWindow = null

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
## func _on_console_close(console:DialogueConsole) -> void:
## 	# Associated signal:  window_closed
## 	# Will run when the DialogueConsole is closed.
## [/codeblock]
func subscribeToConsole(subscriber) -> void:
	if not enabled:
		return

	_addSubscriber(subscriber, _dialogueConsoleSubscribers, _connectConsoleSignalsToSubscriber)

## Unsubscribes a node from the [DialogueConsole], meaning it won't run any
## functions when the [DialogueConsole] emits signals.
func unsubscribeToConsole(subscriber) -> void:
	if not enabled:
		return

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
	if not enabled:
		return

	_addSubscriber(subscriber, _blueprintWindowSubscribers, _connectBlueprintSignalsToSubscriber)

## Unsubscribes a node from the [BlueprintWindow], meaning it won't run any
## functions when the [BlueprintWindow] emits signals.
func unsubscribeToBlueprintWindow(subscriber) -> void:
	if not enabled:
		return

	_removeSubscriber(subscriber, _blueprintWindowSubscribers, _disconnectBlueprintSignalsToSubscriber)

## Pushes a text entry to the [DialogueConsole].
## [br][br]
## [code]metadata[/code] can have the following fields:
## [codeblock]
## "writeSpeed":  # a float for the number of characters per second to display.
##    "instant":  # if the text should be displayed instantly.
##      "theme":  # the text theme to apply to this entry.
## [/codeblock]
func pushMessageToConsole(message:String, metadata:Dictionary = {}) -> void:
	if not enabled:
		return

	if not dialogueConsole:
		return

	dialogueConsole.addExternalEntry(message, metadata)

## Checks if a position is within the screen.
## [code]threshold[/code] is the amount, in pixels, beyond the screen the position can be.
func positionOnScreen(pos:Vector2, threshold:float = 0) -> bool:
	var screen_size := _getScreenSize()

	var min_x := -threshold
	var min_y := -threshold
	var max_x := screen_size.x + threshold
	var max_y := screen_size.y + threshold

	return pos.x >= min_x and pos.x <= max_x and pos.y >= min_y and pos.y <= max_y

## Gets a random position on screen.
## [br][br]
## [code]window_size[/code] is the size of the window to consider.
## [br][br]
## [code]allowOverlap[/code] is a list of window types that this position can overlap.
## The type of a window is defined by [member DialogueWindow.windowType]
func getRandomPositionOnScreen(window_size: Vector2, allowOverlap:Array[String] = []) -> Vector2:
	var viewport_size := _getScreenSize()
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

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Finishes creating a window.
func _addWindow(window:DialogueWindow) -> void:
	Player.disableInput(self)
	CursorHandler.showForce(self)

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
## Moves the window back onto the screen if it's outside the threshold.
func _setWindowOnScreen(window:DialogueWindow, threshold:float = 0) -> void:
	var screen_size := _getScreenSize()
	var window_size := window.size

	var min_x := -threshold
	var min_y := -threshold
	var max_x := screen_size.x - window_size.x + threshold
	var max_y := screen_size.y - window_size.y + threshold

	window.global_position.x = clamp(window.global_position.x, min_x, max_x)
	window.global_position.y = clamp(window.global_position.y, min_y, max_y)

## [b]Internal-use only.[/b]
## Gets the viewport's size.
func _getScreenSize() -> Vector2:
	return get_viewport().get_visible_rect().size

## [b]Internal-use only.[/b]
## Get the center of the screen.
func _getCenter(windowSize:Vector2) -> Vector2:
	return (_getScreenSize() - windowSize) / 2

## [b]Internal-use only.[/b]
## Gets a position for a window on the left side of the screen.
func _getLeftSidePosition(windowSize: Vector2, margin: float = 180.0) -> Vector2:
	var screenSize:Vector2 = _getScreenSize()
	return Vector2(margin, (screenSize.y - windowSize.y) / 3)

## [b]Internal-use only.[/b]
## Gets a position for a window on the right side of the screen.
func _getRightSidePosition(windowSize: Vector2, margin: float = 180.0) -> Vector2:
	var screenSize: Vector2 = _getScreenSize()
	return Vector2(screenSize.x - windowSize.x - margin, (screenSize.y - windowSize.y) / 3)
# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when a window is closed.
func _on_window_closed(closedWindow:DialogueWindow) -> void:
	if closedWindow in _spawnedWindows:
		_spawnedWindows.erase(closedWindow)
		if _spawnedWindows.size() == 0:
			Player.enableInput(self)
			CursorHandler.restoreDefault()

	if closedWindow.windowType not in ["console", "blueprint", "blueprint_detail"]:
		closedWindow.kill()

## [b]Internal-use only.[/b]
## Handless logic for when a window is dropped.
func _on_window_dropped(droppedWindow:DialogueWindow) -> void:
	var cornerPositions:Dictionary[String, Vector2] = droppedWindow.getGlobalCornerPositions()
	for cornerPosition:Vector2 in cornerPositions.values():
		if not positionOnScreen(cornerPosition, droppedWindow.offscreenThresold):
			_setWindowOnScreen(droppedWindow, droppedWindow.offscreenThresold)
			break

## [b]Internal-use only.[/b]
## Handles logic for when a [DialogueConsole] is closed.
func _on_dialogue_console_closed(_window:DialogueWindow) -> void:
	killDialogueConsole()

## [b]Internal-use only.[/b]
## Handles logic for when a [BlueprintWindow] is closed.
func _on_blueprint_window_closed(_window:DialogueWindow) -> void:
	killBlueprintWindow()

## [b]Internal-use only.[/b]
## Handles logic for when a [BlueprintNpcDetailWindow] is closed.
func _on_blueprint_detail_window_closed(_window:DialogueWindow) -> void:
	killBlueprintNpcDetailWindow()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
