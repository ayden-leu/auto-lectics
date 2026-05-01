extends DC_FieldOption
class_name DC_TextTheme

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

const _TEXT_THEME_PRESETS_THEME:Theme = preload("uid://cn85v71yksayt")


# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Used to get and set the currently selected text theme.  Possible themes are stored in the [code]text_theme_presets.tres[/code] file.
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## [br][br]
## Usage:
## [codeblock]
## var textThemeField:DC_TextTheme = # a pre-configured node from the scene tree
##
## # Get the current mode of this [DC_DialogueNode]
## print(textThemeField.textTheme)  # output: "_test_one"
## 
## # Set the mode of this [DC_DialogueNode]
## textThemeField.textTheme = "_test_two"
## [/codeblock]
var textTheme:String:
	set(newTheme):
		chooser.selected = valueToOptionIndex[newTheme]
	get():
		return chooser.get_item_text(chooser.selected)

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	fillValueToOptionIndex(
		_TEXT_THEME_PRESETS_THEME.get_type_list(), false
	)

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
## [b]Internal-use only.[/b]  Handles logic when a atext theme is selected.
func _on_chooser_updated(_index:int) -> void:
	super(_index)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
