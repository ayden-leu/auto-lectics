@icon("uid://cndeeev647s54")
extends Node
class_name CursorHandler
## Helper script to handle cursor state.
##
## Since there are multiple things that can mess with the cursor,
## a state-machine-like system was created to handle it.
## But in short, run [method show]/[method hide] if you don't want to mess with
## other node's wants, and run [method showForce]/[method hideForce] if you
## really need the mouse in a certain mode.
## [br][br]
## If you're just starting the game or loading an environment, use
## [method showNuclear] or [method hideNuclear].

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
## [b]Internal-use only.[/b]
## The default cursor mode that gets restored upon calling [method restoreCursorMode].
static var _defaultCursorMode:Input.MouseMode
## [b]Internal-use only.[/b]
## A list of nodes that want to hide the cursor.
static var _nodesHidingCursor:Dictionary[Node, Node] = {}
## [b]Internal-use only.[/b]
## A list of nodes that want to show the cursor.
static var _nodesShowingCursor:Dictionary[Node, Node] = {}

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Attempts to show the cursor.
## [br][br]
## [b]Case 1:  Cursor is hidden[/b]
## [br]
## If the node calling this didn't hide it previously, nothing happens.
## Else, remove them from [_nodesHidingCursor] and continue.
## [br]
## If [_nodesHidingCursor] is empty after that, then the cursor will show itself.
## [br][br]
## [b]Case 2:  Cursor is visible[/b]
## [br]
## Add the caller node to [member _nodesShowingCursor].
static func show(shower:Node) -> void:
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			if not shower in _nodesHidingCursor and not _nodesHidingCursor.is_empty():
				print("CursorHandler/show():  Shower [", shower.name, "] didn't hide the cursor.")
				return

			print("CursorHandler/show():  Decrementing hide cursor counter.")
			_nodesHidingCursor.erase(shower)
			_printHidingList("CursorHandler/show():  ")
			if _nodesHidingCursor.is_empty():
				print("CursorHandler/show():  Showing cursor due to [", shower.name, "].")
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				_nodesShowingCursor[shower] = null
				_printShowingList("CursorHandler/show():  ")

		Input.MOUSE_MODE_VISIBLE:
			print("CursorHandler/show():  Incrementing show cursor counter.")
			_nodesShowingCursor[shower] = null
			_printShowingList("CursorHandler/show():  ")
		_:
			printerr("CursorHandler/show():  Unhandled mouse mode.")

## Attempts to hide the cursor.
## [br][br]
## [b]Case 1:  Cursor is hidden[/b]
## [br]
## Add the caller node to [member _nodesHidingCursor].
## [br][br]
## [b]Case 2:  Cursor is visible[/b]
## [br]
## If the node calling this didn't show it previously, nothing happens.
## Else, remove them from [_nodesShowingCursor] and continue.
## [br]
## If [_nodesShowingCursor] is empty after that, then the cursor will hide itself.
static func hide(hider:Node) -> void:
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			print("CursorHandler/hide():  Incrementing hide cursor counter.")
			_nodesHidingCursor[hider] = null
			_printHidingList("CursorHandler/hide():  ")
		Input.MOUSE_MODE_VISIBLE:
			if not hider in _nodesShowingCursor and not _nodesShowingCursor.is_empty():
				print("CursorHandler/hide():  Hider [", hider.name, "] didn't show cursor.")
				return

			print("CursorHandler/hide():  Decrementing show cursor counter.")
			_nodesShowingCursor.erase(hider)
			_printShowingList("CursorHandler/hide():  ")
			if _nodesShowingCursor.is_empty():
				print("CursorHandler/hide():  Hiding cursor due to [", hider.name, "]")
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				_nodesHidingCursor[hider] = null
				_printHidingList("CursorHandler/hide():  ")

		_:
			printerr("CursorHandler/hide():  Unhandled mouse mode.")

## Forcibly shows the cursor.
## This also clears [member _nodesHidingCursor] and adds the caller node to [member _nodesShowingCursor]
## if the cursor was previously hidden.
static func showForce(shower:Node) -> void:
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			print("CursorHandler/showForce():  Forcing cursor to be shown due to [", shower.name, "].")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_nodesHidingCursor.clear()
			_nodesShowingCursor[shower] = null
			_printShowingList("CursorHandler/showForce():  ")

		Input.MOUSE_MODE_VISIBLE:
			print("CursorHandler/showForce():  Cursor already shown; no need to force it.")

		_:
			printerr("CursorHandler/showForce():  Unhandled mouse mode.")

## Forcibly hides the cursor.
## This also clears [member _nodesShowingCursor] and adds the caller node to [member _nodesHidingCursor]
## if the cursor was previously shown.
static func hideForce(hider:Node) -> void:
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			print("CursorHandler/hideForce():  Cursor already hidden.")

		Input.MOUSE_MODE_VISIBLE:
			print("CursorHandler/hideForce():  Forcing cursor to be hidden due to [", hider.name, "].")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_nodesShowingCursor.clear()
			_nodesHidingCursor[hider] = null
			_printHidingList("CursorHandler/hideForce():  ")

		_:
			printerr("CursorHandler/hideForce():  Unhandled mouse mode.")

## Same as [method showForce] but clears both [member _nodesShowingCursor]
## and [_nodesHidingCursor].
static func showNuclear() -> void:
	print("CursorHandler:  Nuclear show.")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_nodesShowingCursor.clear()
	_nodesHidingCursor.clear()

## Same as [method hideForce] but clears both [member _nodesShowingCursor]
## and [_nodesHidingCursor].
static func hideNuclear() -> void:
	print("CursorHandler:  Nuclear hide.")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#print_rich("[color=blue]NUCLEARR[/color]")
	_nodesShowingCursor.clear()
	_nodesHidingCursor.clear()

## Sets [member _defaultCursorMode].
## [br]
## [b]Valid choices:[/b]
## [code]"shown"[/code], [code]"hidden"[/code].
static func setDefault(mode:String) -> void:
	match mode:
		"shown":
			print("CursorHandler/setDefault():  Default cursor mode is now [shown/visible].")
			_defaultCursorMode = Input.MOUSE_MODE_VISIBLE
		"hidden":
			print("CursorHandler/setDefault():  Default cursor mode is now [hidden/captured].")
			_defaultCursorMode = Input.MOUSE_MODE_CAPTURED

## Sets the cursor mode to whatever value is in [member _defaultCursorMode].
static func restoreDefault() -> void:
	print("CursorHandler/restoreDefault():  Restoring default cursor mode: ", _defaultCursorMode)
	_nodesShowingCursor.clear()
	_nodesHidingCursor.clear()
	Input.mouse_mode = _defaultCursorMode

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Prints the current members in [member _nodesShowingCursor].
static func _printShowingList(prefix:String = "", suffix:String = "") -> void:
	print(prefix, "Showing - ", _nodesShowingCursor.size(), ": ", _nodesShowingCursor, suffix)

## [b]Internal-use only.[/b]
## Prints the current members in [member _nodesHidingCursor].
static func _printHidingList(prefix:String = "", suffix:String = "") -> void:
	print(prefix, "Hiding - ", _nodesHidingCursor.size(), ": ", _nodesHidingCursor, suffix)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
