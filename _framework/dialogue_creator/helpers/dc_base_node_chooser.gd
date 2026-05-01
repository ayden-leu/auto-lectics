extends DC_BaseNodeField
class_name DC_BaseNodeChooser

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Emitted when the chosen value is updated via code.
signal chooser_updated_via_code(chosen:String)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The chooser for this field.
@export var chooser:OptionButton

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The chosen value for this field.
var chosen:String:
	get():
		return chooser.get_item_text(chooser.selected)
	set(newChosen):
		chooser.selected = _valueToOptionIndex[newChosen]
		chooser_updated_via_code.emit(newChosen)

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## ## [b]Internal-use only.[/b]
## Helper variable to convert option values to their list index.
var _valueToOptionIndex:Dictionary = {
	"npcDefault": 0
}

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Adds [code]referenceArray[/code] entries into [member chooser]
## and records their index into [member _valueToOptionIndex].
func _fillValueToOptionIndex(referenceArray:Array[String]) -> void:
	var prefillSize:int = chooser.item_count
	
	for i:int in range(referenceArray.size()):
		var value:String = referenceArray[i]
		chooser.add_item(value)
		_valueToOptionIndex.set(value, i + prefillSize)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when an option is picked by the user.
func _on_chooser_item_selected(_index:int) -> void:
	field_updated.emit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
