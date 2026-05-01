extends DC_BaseNodeChooser
class_name DC_NodeSfxEventField

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
## The label that displays this field's [DialogueDefaults.SFX_EVENTS] ID.
@export var label:Label

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The ID of the [DialogueDefaults.SFX_EVENTS] that this field modifies.
## [member label] get's automatically updated to this member's value when it is set.
var eventID:String = "":
	set(value):
		eventID = value
		label.text = value.capitalize()

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Removes the first option entry of each spawned SFX ID entry.
## Is a work-around to remove "npcDefault" for each entry.
func removeFirstEntry() -> void:
	chooser.remove_item(0)

## Setups the option entries.
## Part of the work around mentioned in [method removeFirstEntry].
func setup() -> void:
	var temp:Array[String] = ["none", "inherit"]
	temp.append_array(DirAccess.get_directories_at(FR_Globals.STORAGE_PATH.SFX))
	_fillValueToOptionIndex(temp)

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
