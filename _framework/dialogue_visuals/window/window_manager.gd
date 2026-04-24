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
## [b]Internal-use only.[/b]  A reference to the [DialogueConsole] scene.
const _DIALOGUE_CONSOLE_SCENE:Resource = preload(FR_Globals.SCENES.DialogueConsoleWindow)
## [b]Internal-use only.[/b]  A reference to the [DialogueConsoleOptionWindow] scene.
const _OPTION_WINDOW_SCENE:Resource = preload(FR_Globals.SCENES.DialogueConsoleOptionWindow)

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
## [b]Internal-use only.[/b]  Holds all windows created by the manager.
var _spawnedWindows:Array[DialogueWindow]
## [b]Internal-use only.[/b]  Holds all nodes that want to listen
## to [DialogueConsole]'s signals.
var _dialogueConsoleSubscribers:Array

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
		dialogueConsole = null

## Creates a [DialogueConsoleOptionWindow].  Not pre-configured.
func createDialogueOptionWindow() -> DialogueConsoleOptionWindow:
	var optionWindow:DialogueConsoleOptionWindow = _OPTION_WINDOW_SCENE.instantiate()
	_addWindow(optionWindow)
	return optionWindow

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
## [/codeblock] 
func subscribeToConsole(subscriber) -> void:
	_dialogueConsoleSubscribers.push_back(subscriber)
	_connectSignalsToSubscriber(subscriber)

## Unsubscribes a node from the [DialogueConsole], meaning it won't run any
## functions when the [DialogueConsole] emits signals.
func unsubscribeToConsole(subscriber) -> void:
	if not subscriber in _dialogueConsoleSubscribers:
		return
	
	var subscriberIndex:int = _dialogueConsoleSubscribers.find(subscriber)
	_dialogueConsoleSubscribers[subscriberIndex] = null
	_disconnectSignalsToSubscriber(subscriber)

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Finishes creating a window.
func _addWindow(window:DialogueWindow) -> void:
	add_child(window)
	_spawnedWindows.push_back(window)
	window.window_closed.connect(_on_window_closed)

## [b]Internal-use only.[/b]  Connects the [DialogueConsole] signals to
## functions defined by the subscriber.
func _connectSignalsToSubscriber(subscriber) -> void:
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
	
	# TODO:  remove this when the better command system is in place
	if subscriber.has_method("_on_console_open_gate"):
		dialogueConsole.open_gate.connect(subscriber._on_console_open_gate)
	

## [b]Internal-use only.[/b]  Connects the [DialogueConsole] signals to
## functions defined by the subscriber.
func _disconnectSignalsToSubscriber(subscriber) -> void:
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

## [b]Internal-use only.[/b]  Removes all [code]null[/code] entries
## in [member _dialogueConsoleSubscribers].
func _cleanSubscriberList() -> void:
	var newList:Array = []
	for subscriber in _dialogueConsoleSubscribers:
		if subscriber == null:
			continue
		newList.push_back(subscriber)
	_dialogueConsoleSubscribers.clear()
	_dialogueConsoleSubscribers = newList

## [b]Internal-use only.[/b]  Resubscribes all [DialogueConsole] subscribers to
## [DialogueConsole]'s signals.
func _resubscribeSubscribers() -> void:
	for subscriber in _dialogueConsoleSubscribers:
		_connectSignalsToSubscriber(subscriber)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when a window is closed.
func _on_window_closed(closedWindow:DialogueWindow) -> void:
	#print("before: ", _spawnedWindows)
	closedWindow.queue_free()
	_spawnedWindows.erase(closedWindow)
	#print("after: ", _spawnedWindows)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
