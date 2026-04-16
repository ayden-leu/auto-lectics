extends DC_FieldOption
class_name DC_SfxEventFieldOption
## [b]Internal-use only.[/b]  Handles the chosen SFX ID of a [DialogueDefaults.SFX_EVENTS].
## SFX IDs are the names of folders located in "sounds/sfx/".

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

## Used to get and set the SFX ID for a [member DialogueDefaults.SFX_EVENTS], which is determined by [member eventID].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## [br][br]
## Usage:
## [codeblock]
## var sfxField:DC_SfxEventFieldOption = # a pre-configured node from the scene tree
##
## # Get the SFX ID of this SFX event
## print(sfxField.option)  # output: "none"
## 
## # Set the SFX ID of this SFX event
## sfxField.option = "inherit"
## [/codeblock]
var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
	get():
		return _sfxIDs[chooser.selected]

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  All possible SFX IDs.
var _sfxIDs:Array[String] = ["none", "inherit"]

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_sfxIDs.append_array(DirAccess.get_directories_at(FR_Globals.STORAGE_PATH.SFX))
	fillValueToOptionIndex(_sfxIDs, false)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
