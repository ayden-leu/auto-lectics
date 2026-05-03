@icon("uid://bfg0nlmruxfhi")
extends Node
class_name WindowManager

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
## A reference to the [DialogueConsole] scene.
const _DIALOGUE_CONSOLE_SCENE:Resource = preload(FR_Globals.SCENES.DialogueConsoleWindow)
## [b]Internal-use only.[/b]
## A reference to the [DialogueConsoleOptionWindow] scene.
const _OPTION_WINDOW_SCENE:Resource = preload(FR_Globals.SCENES.DialogueConsoleOptionWindow)
## [b]Internal-use only.[/b] Contains reference to the warning tile scene where warnings will spawn
const _WARNING_LAYER_SCENE: PackedScene = preload(FR_Globals.SCENES.DialogueWarningTile)

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

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Holds all windows created by the manager.
var _spawnedWindows:Array[DialogueWindow]
## [b]Internal-use only.[/b]
## Holds all nodes that want to listen to [DialogueConsole]'s signals.
var _dialogueConsoleSubscribers:Array
## Holds WARNING_LAYER_SCENE when one needs to be instantiated
var dialogue_warning_tile: DialogueWarningTile = null

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Creates a [DialogueConsole].  Only one can exist at a time.  Not pre-configured.
func createDialogueConsole() -> DialogueConsole:
	if dialogueConsole != null:
		return dialogueConsole
	
	dialogueConsole = _DIALOGUE_CONSOLE_SCENE.instantiate()
	_addWindow(dialogueConsole)
	_cleanSubscriberList()
	_resubscribeSubscribers()
	return dialogueConsole

## Kills the current [DialogueConsole].
func killDialogueConsole() -> void:
	if dialogueConsole != null:
		dialogueConsole.kill()
		_on_window_closed(dialogueConsole)
		dialogueConsole = null

## Creates a [DialogueConsoleOptionWindow].  Not pre-configured.
func createDialogueOptionWindow() -> DialogueConsoleOptionWindow:
	var optionWindow:DialogueConsoleOptionWindow = _OPTION_WINDOW_SCENE.instantiate()
	_addWindow(optionWindow)
	return optionWindow
	
## Creates a [DialogueWarningTile], while avoiding the main console
func createDialogueWarningTile() -> DialogueWarningTile:
	dialogue_warning_tile = _WARNING_LAYER_SCENE.instantiate()
	_addWindow(dialogue_warning_tile)
	dialogue_warning_tile.spawn_warnings()
	return dialogue_warning_tile

## [b]Internal-use only.[/b]  Delete [DialogueWarningTile]
func deleteDialogueWarningTile() -> void:
	if dialogue_warning_tile != null:
		dialogue_warning_tile.close()
		dialogue_warning_tile = null

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
## [/codeblock] 
func subscribeToConsole(subscriber) -> void:
	if subscriber in _dialogueConsoleSubscribers:
		return
	
	_dialogueConsoleSubscribers.push_back(subscriber)
	_connectConsoleSignalsToSubscriber(subscriber)

## Unsubscribes a node from the [DialogueConsole], meaning it won't run any
## functions when the [DialogueConsole] emits signals.
func unsubscribeToConsole(subscriber) -> void:
	if not subscriber in _dialogueConsoleSubscribers:
		return
	
	var subscriberIndex:int = _dialogueConsoleSubscribers.find(subscriber)
	_dialogueConsoleSubscribers[subscriberIndex] = null
	_disconnectConsoleSignalsToSubscriber(subscriber)

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
## Input should be window.size, and self.get_global_rect() for main console
func getRandomPositionOnScreen(window_size: Vector2) -> Vector2:
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
	add_child(window)
	_spawnedWindows.push_back(window)
	window.window_closed.connect(_on_window_closed)
	window.window_dropped.connect(_on_window_dropped)
	
	await get_tree().process_frame
	_setWindowOnScreen(window, window.offscreenThresold)

## [b]Internal-use only.[/b]
## Connects the [DialogueConsole] signals to functions defined by the subscriber.
func _connectConsoleSignalsToSubscriber(subscriber) -> void:
	if not dialogueConsole:
		return
	
	if subscriber.has_method("_on_console_option_chosen"):
		dialogueConsole.option_chosen.connect(subscriber._on_console_option_chosen)
	if subscriber.has_method("_on_console_all_dialogue_text_visible"):
		dialogueConsole.all_dialogue_text_visible.connect(subscriber._on_console_all_dialogue_text_visible)
	if subscriber.has_method("_on_console_new_option_available"):
		dialogueConsole.new_option_available.connect(subscriber._on_console_new_option_available)
	if subscriber.has_method("_on_console_all_options_available"):
		dialogueConsole.all_options_available.connect(subscriber._on_console_all_options_available)
	if subscriber.has_method("_on_console_command_entered"):
		dialogueConsole.command_entered.connect(subscriber._on_console_command_entered)

## [b]Internal-use only.[/b]
## Connects the [DialogueConsole] signals to functions defined by the subscriber.
func _disconnectConsoleSignalsToSubscriber(subscriber) -> void:
	if not dialogueConsole:
		return
	
	if subscriber.has_method("_on_console_option_chosen"):
		dialogueConsole.option_chosen.disconnect(subscriber._on_console_option_chosen)
	if subscriber.has_method("_on_console_all_dialogue_text_visible"):
		dialogueConsole.all_dialogue_text_visible.disconnect(subscriber._on_console_all_dialogue_text_visible)
	if subscriber.has_method("_on_console_new_option_available"):
		dialogueConsole.new_option_available.disconnect(subscriber._on_console_new_option_available)
	if subscriber.has_method("_on_console_all_options_available"):
		dialogueConsole.all_options_available.disconnect(subscriber._on_console_all_options_available)
	if subscriber.has_method("_on_console_command_entered"):
		dialogueConsole.command_entered.disconnect(subscriber._on_console_command_entered)

## [b]Internal-use only.[/b]
## Removes all [code]null[/code] entries in [member _dialogueConsoleSubscribers].
func _cleanSubscriberList() -> void:
	var newList:Array = []
	for subscriber in _dialogueConsoleSubscribers:
		if subscriber == null:
			continue
		newList.push_back(subscriber)
	_dialogueConsoleSubscribers.clear()
	_dialogueConsoleSubscribers = newList

## [b]Internal-use only.[/b]
## Resubscribes all [DialogueConsole] subscribers to [DialogueConsole]'s signals.
func _resubscribeSubscribers() -> void:
	for subscriber in _dialogueConsoleSubscribers:
		_connectConsoleSignalsToSubscriber(subscriber)

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

## Moves this window to the center of the screen immediately.
func _centerWindow(window:DialogueWindow) -> void:
	window.global_position = (get_viewport().get_visible_rect().size - window.size) / 2
	
# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when a window is closed.
func _on_window_closed(closedWindow:DialogueWindow) -> void:
	if closedWindow in _spawnedWindows:
		_spawnedWindows.erase(closedWindow)

## [b]Internal-use only.[/b]
func _on_window_dropped(droppedWindow:DialogueWindow) -> void:
	var cornerPositions:Dictionary[String, Vector2] = droppedWindow.getGlobalCornerPositions()
	for cornerPosition:Vector2 in cornerPositions.values():
		if not positionOnScreen(cornerPosition, droppedWindow.offscreenThresold):
			_setWindowOnScreen(droppedWindow, droppedWindow.offscreenThresold)
			break

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
