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
## The mouse mode before [method showCursorTemp] or [method hideCursorTemp] was ran.
static var _baseMouseMode:Input.MouseMode = Input.MOUSE_MODE_MAX
## [b]Internal-use only.[/b]
##
static var _prevMouseModeStack:Array[Input.MouseMode] = []
## [b]Internal-use only.[/b]
##
static var _nodeToStackIndex:Array[Node] = []

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## to write
static func showCursor() -> void:
	print("Cursor forced to be visible.")
	_baseMouseMode = Input.MOUSE_MODE_VISIBLE

	if _prevMouseModeStack.is_empty():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## to write
static func hideCursor() -> void:
	print("Cursor forced to be captured.")
	_baseMouseMode = Input.MOUSE_MODE_CAPTURED

	if _prevMouseModeStack.is_empty():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## to write
static func showCursorTemp(caller:Node) -> void:
	print("Cursor temporarily shown.")
	_nodeToStackIndex.push_back(caller)
	_prevMouseModeStack.push_back(Input.mouse_mode)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	print(_nodeToStackIndex)
	print(_prevMouseModeStack)

## to write
static func hideCursorTemp(caller:Node) -> void:
	print("Cursor temporarily hidden.")
	_nodeToStackIndex.push_back(caller)
	_prevMouseModeStack.push_back(Input.mouse_mode)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## to write
static func _removeFromStack(toRemove:Node) -> void:
	var index:int = _nodeToStackIndex.find(toRemove)
	_prevMouseModeStack.remove_at(index)
	_nodeToStackIndex.remove_at(index)
	_nodeToStackIndex.erase(toRemove)

## to write
static func restoreCursorMode(caller:Node) -> void:
	print(_nodeToStackIndex)
	print(_prevMouseModeStack)

	if _nodeToStackIndex.find(caller) == _prevMouseModeStack.size()-1 \
		and not _nodeToStackIndex.is_empty() and not _prevMouseModeStack.is_empty():
		_nodeToStackIndex.erase(caller)
		Input.set_mouse_mode(_prevMouseModeStack.pop_back())
		print("Previous cursor state restored.")
	else:
		_removeFromStack(caller)

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
