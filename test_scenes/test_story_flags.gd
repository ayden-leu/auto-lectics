extends Control

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

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
@onready var flagField:OptionButton = %FlagField
@onready var flagStatus:CheckBox = %FlagStatus
@onready var newFlagStatus:CheckBox = %NewFlagStatus
@onready var checkingValue:CheckBox = %Checking
@onready var checkStatus:Label = %Result

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_loadOptionButtonOptions(
		flagField,
		_getFlags().keys()
	)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _loadOptionButtonOptions(button:OptionButton, options:Array) -> void:
	for option in options:
		button.add_item(option)
	button.selected = 0

func _clearOptionButtonOptions(button:OptionButton) -> void:
	for _i in range(button.item_count):
		button.remove_item(0)

func _getFlags() -> Dictionary:
	return StoryFlags.currentFlags

func _updateFlagStatus() -> void:
	var flagID:String = flagField.get_item_text(flagField.selected)
	flagStatus.button_pressed = _getFlags()[flagID]

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_flag_field_item_selected(_index: int) -> void:
	_updateFlagStatus()

func _on_set_flag_value_pressed() -> void:
	var flagID:String = flagField.get_item_text(flagField.selected)
	var gathered:Dictionary = {}
	gathered[flagID] = newFlagStatus.button_pressed
	StoryFlags.updateFlags(gathered)
	
	_updateFlagStatus()

func _on_reset_flag_values_pressed() -> void:
	StoryFlags.resetFlags()
	_updateFlagStatus()

func _on_check_button_pressed() -> void:
	var flagID:String = flagField.get_item_text(flagField.selected)
	var toCheckAgainst:Dictionary = {}
	toCheckAgainst[flagID] = %Checking.button_pressed
	
	if StoryFlags.flagsMatch(toCheckAgainst):
		checkStatus.text = "yes"
	else:
		checkStatus.text = "nuh uh"

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
