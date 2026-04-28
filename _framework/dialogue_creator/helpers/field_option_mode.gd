extends DC_FieldOption
class_name DC_ModeFieldOption
## [b]Internal-use only.[/b]  Handles the mode for a [DC_DialogueNode].

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the current mode is set to "hectic."
signal set_hectic_port(on:bool)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The label that denotes the hectic port.
@export var hecticPortLabel:Label

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Used to get and set the currently selected dialogue mode.  Possible values are stored in [member DialogueDefaults.DIALOGUE_MODES].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## [br][br]
## Usage:
## [codeblock]
## var modeField:DC_ModeFieldOption = # a pre-configured node from the scene tree
##
## # Get the current mode of this [DC_DialogueNode]
## print(modeField.option)  # output: "normal"
## 
## # Set the mode of this [DC_DialogueNode]
## modeField.option = "hectic"
## [/codeblock]
var option:String:
	set(newOption):
		chooser.selected = valueToOptionIndex[newOption]
		_on_chooser_updated(valueToOptionIndex[newOption])
	get():
		return DialogueDefaults.DIALOGUE_MODES[chooser.selected]

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	fillValueToOptionIndex(DialogueDefaults.DIALOGUE_MODES)
	hecticPortLabel.visible = false
	
	option = DialogueDefaults.DEFAULT_DIALOGUE.mode

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Simulates choosing "hectic" in the [member chooser].
func enableHecticPort() -> void:
	_on_chooser_updated(valueToOptionIndex.hectic)

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when the [member chooser]'s value gets updated. 
func _on_chooser_updated(index: int) -> void:
	var isHectic:bool = (DialogueDefaults.DIALOGUE_MODES[index] == "hectic")
	
	hecticPortLabel.visible = isHectic
	set_hectic_port.emit(isHectic)
	super(index)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
