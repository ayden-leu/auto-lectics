extends Control
## This is auto-loaded into the game as DebugHud.
##
## To show/hide, press thee "toggle_debug_hud"" keybind (shift + quote left (`/~ key)).
## While this is visible, it eats all mouse inputs.  Can't fix this without making
## the scroll part of it not work.
## [br][br]
## To add an entry to the log, run [method addToLog].

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------
## The various types of entries to add to the [member _log].
enum LogType {
	NORMAL,  ## White text
	WARNING, ## Gold text
	ERROR,   ## Light Coral text
	GOOD,    ## Green text
	BAD      ## Red text
}
## The colors for each [enum LogType].
const LogTypeColor:Dictionary[LogType, String] = {
	LogType.NORMAL: "[color=white]",
	LogType.WARNING: "[color=gold]",
	LogType.ERROR: "[color=light_coral]",
	LogType.GOOD: "[color=green]",
	LogType.BAD: "[color=red]"
}

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
## The thing that holds all of the logs.
@onready var _log:Container = %Log
## [b]Internal-use only.[/b]
## The thing that does the scrolling for all of the logs.
@onready var _logScrollContainer: ScrollContainer = %LogScrollContainer
## [b]Internal-use only.[/b]
## The thing that holds all of the checklist-related stuff.
@onready var _checklistArea: VBoxContainer = %ChecklistArea
## [b]Internal-use only.[/b]
## The thing that holds all of the checklist entries.
@onready var _checklist: VBoxContainer = %Checklist
## [b]Internal-use only.[/b]
## The thing that does the scrolling for all of the checklist entries.
@onready var _checklistScrollContainer: ScrollContainer = %ChecklistScrollContainer

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
	hide()
	_checklistArea.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_hud"):
		if visible:
			#addToLog("Hiding debug hud.")
			visible = false
		else:
			#addToLog("Showing debug hud.")
			visible = true

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Adds the given message to the log, as well as the built-in debugger and terminal.  Can optionally take in a [enum LogType].
func addToLog(message:String, type:LogType = LogType.NORMAL) -> void:
	var newEntry:RichTextLabel = RichTextLabel.new()
	_log.add_child(newEntry)

	var seperator:HSeparator = HSeparator.new()
	_log.add_child(seperator)

	newEntry.bbcode_enabled = true
	newEntry.custom_minimum_size.y = 25.0
	newEntry.size_flags_vertical = Control.SIZE_SHRINK_END
	newEntry.fit_content = true

	newEntry.text = "" + LogTypeColor[type]
	newEntry.text += message
	newEntry.text += "[/color]"

	match type:
		LogType.WARNING:
			push_warning(message)
		LogType.ERROR:
			push_error(message)
		_:
			print_rich(message)

	await get_tree().process_frame
	_logScrollContainer.scroll_vertical = ceil(_logScrollContainer.get_v_scroll_bar().max_value)

## Adds a checklist entry to [member _checklist] and names it with the given entry name.
func addChecklistEntry(entryName:String) -> void:
	_checklistArea.show()

	var container:HBoxContainer = HBoxContainer.new()
	var label:Label = Label.new()
	var checker:CheckBox = CheckBox.new()
	var separator:HSeparator = HSeparator.new()
	_checklist.add_child(container)
	_checklist.add_child(separator)
	container.add_child(label)
	container.add_child(checker)

	container.size_flags_horizontal = Control.SIZE_SHRINK_END
	label.text = entryName

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
