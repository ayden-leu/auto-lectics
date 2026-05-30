@tool
extends Menu
## A menu that lets players see the current keybinds.
##
## You cannot rebind keybinds currently, only view them.
## [br][br]
## Comes with one button:[br]
## - To close this menu.[br]
## [br][br]
## Not [i]every[/i] keybind is listed, since there are some that are not used
## for anything in the actual game.
## Refer to [member _actionsToSkip] for a list of keybinds that are skipped.
## [br][br]
## Each keybind entry is formatted to make them look nice.
## Refer to [method _formatActionName] and [method _formatKeybindName] to
## see how they are formatted.
## [br][br]
## Also plays a sound whenever a button is clicked via its [member _sfxEventHandler].

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
## [b]Internal-use only.[/b]
## The holder for each keybind entry.
@onready var _bindingsHolder = %BindingHolder
## [b]Internal-use only.[/b]
## The [SfxEventHandler] for this menu.
@onready var _sfxEventHandler:SfxEventHandler = %SfxEventHandler

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## A list of keybinds to skip over when making keybind entries.
## The code that checks for keybinds checks if the keybind name starts with
## any of the entries in here.
## [br]
## For example, the keybinds [code]ui_left[/code] and [code]ui_right[/code] are
## skipped due to both of them beginning with [code]ui_[/code].
var _actionsToSkip:Array[String] = [
	"ui_", "debug_", "dc_"
]

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	menuID = "keybinds"
	super()  # runs the inherited class' _ready() function.

	_generateKeybindEntries()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Formats a given action name to make it look nice.
## Currently, it replaces all "_" characters with " ".
func _formatActionName(action:String) -> String:
	return action.replace("_", " ").capitalize()

## [b]Internal-use only.[/b]
## Formats a given keybind name to make it look nice.
## Currently, it removes all occurances of "(Physical)".
func _formatKeybindName(keybind:String) -> String:
	return keybind.replace("(Physical)", "")

## [b]Internal-use only.[/b]
## Generates the entries for each keybind to display.
func _generateKeybindEntries() -> void:
	# clear holder of entries just in case.
	for entry in _bindingsHolder.get_children():
		entry.queue_free()

	var actions:Array[StringName] = InputMap.get_actions()
	for action:StringName in actions:
		# skip action if prefix matches entry in _actionsToSkip
		var skip:bool = false
		for skipper:String in _actionsToSkip:
			if action.begins_with(skipper):
				skip = true
				break
		if skip:
			continue

		# generate an entry
		var entry:HBoxContainer = HBoxContainer.new()
		_bindingsHolder.add_child(entry)

		var actionName:String = _formatActionName(action)
		var actionLabel:Label = Label.new()
		actionLabel.text = actionName
		actionLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		entry.add_child(actionLabel)

		var bindingLabel:Label = Label.new()
		var events:Array[InputEvent] = InputMap.action_get_events(action)
		if events.is_empty():
			bindingLabel.text = "(unbound)"
		else:
			var parts:Array[String] = []
			for event in events:
				parts.append(_formatKeybindName(event.as_text()))
			bindingLabel.text = " / ".join(parts)
		bindingLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		bindingLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.add_child(bindingLabel)

		# Divider between entries
		var sep:HSeparator = HSeparator.new()
		_bindingsHolder.add_child(sep)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when the back button is pressed.
func _on_back_pressed() -> void:
	_sfxEventHandler.play("buttonPressed")
	close()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
