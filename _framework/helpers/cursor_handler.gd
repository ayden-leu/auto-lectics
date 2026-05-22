extends Node
class_name CursorHandler
## Helper script to handle cursor state.

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
## to write
static var _defaultCursorMode:Input.MouseMode
## [b]Internal-use only.[/b]
## to write
static var _nodesHidingCursor:Dictionary[Node, Node] = {}
## [b]Internal-use only.[/b]
## to write
static var _nodesShowingCursor:Dictionary[Node, Node] = {}

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## to write
static func show(shower:Node) -> void:
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			if not shower in _nodesHidingCursor and not _nodesHidingCursor.is_empty():
				print("CursorHandler/show():  Shower [", shower.name, "] didn't hide the cursor.")
				return

			print("CursorHandler/show():  Decrementing hide cursor counter.")
			print("CursorHandler/show():  ", _nodesHidingCursor.size(), ": ", _nodesHidingCursor)
			_nodesHidingCursor.erase(shower)
			if _nodesHidingCursor.is_empty():
				print("CursorHandler/show():  Showing cursor due to [", shower.name, "].")
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				_nodesShowingCursor[shower] = null
				print("CursorHandler/show():  ", _nodesShowingCursor.size(), ": ", _nodesShowingCursor)

		Input.MOUSE_MODE_VISIBLE:
			print("CursorHandler/show():  Incrementing show cursor counter.")
			_nodesShowingCursor[shower] = null
			print("CursorHandler/show():  ", _nodesShowingCursor.size(), ": ", _nodesShowingCursor)
		_:
			printerr("CursorHandler/show():  Unhandled mouse mode.")

## to write
static func hide(hider:Node) -> void:
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			print("CursorHandler/hide():  Incrementing hide cursor counter.")
			_nodesHidingCursor[hider] = null
			print("CursorHandler/hide():  ", _nodesHidingCursor.size(), ": ", _nodesHidingCursor)
		Input.MOUSE_MODE_VISIBLE:
			if not hider in _nodesShowingCursor and not _nodesShowingCursor.is_empty():
				print("CursorHandler/hide():  Hider [", hider.name, "] didn't show cursor.")
				return

			print("CursorHandler/hide():  Decrementing show cursor counter.")
			_nodesShowingCursor.erase(hider)
			print("CursorHandler/hide():  ", _nodesShowingCursor.size(), ": ", _nodesShowingCursor)
			if _nodesShowingCursor.is_empty():
				print("CursorHandler/hide():  Hiding cursor due to [", hider.name, "]")
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				_nodesHidingCursor[hider] = null
				print("CursorHandler/hide():  ", _nodesHidingCursor.size(), ": ", _nodesHidingCursor)

		_:
			printerr("CursorHandler/hide():  Unhandled mouse mode.")

## to write
static func showForce(shower:Node) -> void:
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			print("CursorHandler/showForce():  Forcing cursor to be shown due to [", shower.name, "].")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_nodesHidingCursor.clear()
			_nodesShowingCursor[shower] = null
			print("CursorHandler/showForce():  ", _nodesShowingCursor.size(), ": ", _nodesShowingCursor)

		Input.MOUSE_MODE_VISIBLE:
			print("CursorHandler/showForce():  Cursor already shown; no need to force it.")

		_:
			printerr("CursorHandler/showForce():  Unhandled mouse mode.")

## to write
static func hideForce(hider:Node) -> void:
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			print("CursorHandler/hideForce():  Cursor already hidden.")

		Input.MOUSE_MODE_VISIBLE:
			print("CursorHandler/hideForce():  Forcing cursor to be hidden due to [", hider.name, "].")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_nodesShowingCursor.clear()
			_nodesHidingCursor[hider] = null
			print("CursorHandler/hideForce():  ", _nodesHidingCursor.size(), ": ", _nodesHidingCursor)

		_:
			printerr("CursorHandler/hideForce():  Unhandled mouse mode.")

## to write
## choices:  [code]"shown"[/code], [code]"hidden"[/code].
static func setDefault(mode:String) -> void:
	match mode:
		"shown":
			print("CursorHandler/setDefault():  Default cursor mode is now [shown/visible].")
			_defaultCursorMode = Input.MOUSE_MODE_VISIBLE
		"hidden":
			print("CursorHandler/setDefault():  Default cursor mode is now [hidden/captured].")
			_defaultCursorMode = Input.MOUSE_MODE_CAPTURED

## to write
static func restoreDefault() -> void:
	print("CursorHandler/restoreDefault():  Restoring default cursor mode: ", _defaultCursorMode)
	_nodesShowingCursor.clear()
	_nodesHidingCursor.clear()
	Input.mouse_mode = _defaultCursorMode

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
