extends DC_BaseNodeChooser

# feel free to remove sections you're not using
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
## The hectic duration field.
@export var hecticDurationField:HBoxContainer
## The separator for the [member hecticDurationField].
@export var hecticDurationFieldSeparator:HSeparator

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

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_fillValueToOptionIndex(DialogueDefaults.DIALOGUE_MODES)
	hecticPortLabel.visible = false
	hecticDurationField.visible = false
	hecticDurationFieldSeparator.visible = false

	chosen = DialogueDefaults.DEFAULT_DIALOGUE.mode

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Toggles the hectic port on/off.
func toggleHecticPort(on:bool) -> void:
	hecticPortLabel.visible = on
	hecticDurationField.visible = on
	hecticDurationFieldSeparator.visible = on
	set_hectic_port.emit(on)

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Only here to see signal connections.
func _on_chooser_item_selected(index:int) -> void:
	var isHectic:bool = (chooser.get_item_text(index) == "hectic")
	toggleHecticPort(isHectic)

	super(index)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
