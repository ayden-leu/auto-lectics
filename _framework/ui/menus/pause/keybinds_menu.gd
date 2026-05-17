@tool
extends Menu

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
## [b]Internal-use only.[/b]  Holds each keeybind entry.
@onready var _bindingsHolder = %BindingHolder

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

#var subMenu:Menu = preload("uid of menu scene")

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
## [b]Internal-use only.[/b]  A list of keybinds to skip over when making keybind entries.
var _actionsToSkip:Array[String] = [
	"ui_", "debug_", "dc_"
]

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

#func _on_open_submenu_pressed() -> void:
#_TS_open.emit(subMenu)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------





func _generateKeybindEntries() -> void:
	for entry in _bindingsHolder.get_children():
		entry.queue_free()

	var actions:Array[StringName] = InputMap.get_actions()
	for action in actions:
		var skip:bool = false
		for skipper in _actionsToSkip:
			if action.begins_with(skipper):
				skip = true
				break
		if skip:
			continue

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


func _formatActionName(action:String) -> String:
	return action.replace("_", " ").capitalize()

func _formatKeybindName(keybind:String) -> String:
	return keybind.replace("(Physical)", "")

func _on_back_pressed() -> void:
	sfxEventHandler.play("buttonPressed")
	close()
