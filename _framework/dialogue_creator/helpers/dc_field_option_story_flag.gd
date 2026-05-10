extends DC_BaseNodeChooser
class_name DC_StoryFlagChooser
## [b]Internal-use only.[/b]  Handles the state of a flag.
## All flags can be found in [member StoryFlags.DEFAULT_FLAGS].

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this field is being removed from the list.
signal removing(field:DC_StoryFlagChooser)
## Emitted when state of this flag is updated.
signal field_updated_history(oldFlagID:String, newFlagID:String)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The [CheckBox] whose state to check whenever we want to get the state of this flag ID.
@export var toggler:CheckBox

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The [VSeparator] that gets created along with this field.
var separator:VSeparator

## Used to get and set the flag ID this field handles.  All flag IDs can be found in [member StoryFlags.DEFAULT_FLAGS].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## [br][br]
## Usage:
## [codeblock]
## var flagField:DC_StoryFlagChooser = # a pre-configured node from the scene tree
##
## # Get the flag ID this field configures
## print(flagField.flagID)  # output: "testFlag"
##
## # Set the flag ID this field configures
## flagField.flagID = "someOtherFlag"
## [/codeblock]
var flagID:String:
	set(newID):
		chooser.selected = _valueToOptionIndex[newID]
		_prevSelectedFlagID = newID
	get():
		if chooser.selected != -1:
			return chooser.get_item_text(chooser.selected)
		return ""

## Used to get and set the state of this flag.  The flag whose state this refers to is determined by [member flagID].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## [br][br]
## Usage:
## [codeblock]
## var flagField:DC_StoryFlagChooser = # a pre-configured node from the scene tree
##
## # Get the flag ID this field configures
## print(flagField.enabled)  # output: false
##
## # Set the flag ID this field configures
## flagField.enabled = true
## [/codeblock]
var enabled:bool:
	set(newState):
		toggler.button_pressed = newState
	get():
		return toggler.button_pressed

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  The previous flag ID that this field handled.
var _prevSelectedFlagID:String

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Deletes this field.
func _delete() -> void:
	removing.emit(self)
	separator.queue_free()
	queue_free()


# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when the remove button is pressed.
func _on_remove_button_pressed() -> void:
	_delete()

## [b]Internal-use only.[/b]  Runs when either [DC_CheckFlagAspects] or [DC_SetFlagAspects]
## wants to update all flag fields about which flags are available to choose.
func _on_update_available_flags(availableFlags:Array[String]) -> void:
	var tempCopy:Array[String] = availableFlags.duplicate()
	if flagID:
		tempCopy.push_front(flagID)

	_valueToOptionIndex = {}
	for _i in range(chooser.item_count):
		chooser.remove_item(0)
	_fillValueToOptionIndex(tempCopy)

## [b]Internal-use only.[/b]  Runs when [member chooser] gets updated.
## Also sends the old and new flag ID with the signal.
func _on_chooser_updated(_index:int) -> void:
	field_updated_history.emit(_prevSelectedFlagID, flagID)
	_prevSelectedFlagID = flagID

## [b]Internal-use only.[/b]  Runs when the [member toggler] gets fully clicked.
func _on_checkbox_clicked() -> void:
	field_updated.emit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
