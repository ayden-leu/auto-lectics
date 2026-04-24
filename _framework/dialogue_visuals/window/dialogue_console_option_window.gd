@tool
extends DialogueWindow
class_name DialogueConsoleOptionWindow
## [b]Internal-use only.[/b]  A dialogue option window that spawns when a user
## is able to continue a dialogue event.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this option is chosen.
signal option_selected(myself:DialogueConsoleOptionWindow)

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
## The label that denotes which "index" is associated with this option.
@onready var idLabel:Label = %ID
## The label that holds the text associated with this option.
@onready var optionTextLabel:Label = %Text

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The option ID this option window corresponds to.
## [br][br]
## Comes with a getter and setter so you can treat it like a normal variable
## while updating the relevant stuff.
var id:int:
	set(newID):
		id = newID
		idLabel.text = "[%d]" % newID
		
		#if newID != 0:
			#print("readd this?")
			#$ColorRect2.visible = false
			#$Label.visible = false

## The option text of the option this option window corresponds to.
## [br][br]
## Comes with a getter and setter so you can treat it like a normal variable
## while updating the relevant stuff.
var text:String:
	set(newText):
		optionTextLabel.text = newText
	get():
		return optionTextLabel.text

## The data related to this option.
var data:Dictionary

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	super()

func _gui_input(event: InputEvent) -> void:
	super(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_pressed() -> void:
	if not _dragging:
		#print("option selected via button")
		option_selected.emit(self)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	return super()

func _validate_property(property: Dictionary) -> void:
	super(property)
