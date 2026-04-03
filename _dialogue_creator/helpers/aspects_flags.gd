extends VBoxContainer
class_name DC_AspectsFlags
## [b]Internal-use only.[/b]  Used to handle any configured [StoryFlags] for [DC_DialogueNode] and [DC_OptionNode].

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when any field managed by this node is modified.
signal value_changed()
## Emitted when a [member StoryFlags.default_flags] flag is being used by a [DC_StoryFlagFieldOption].
signal update_available_flags()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The node that holds generated [DC_StoryFlagFieldOption] nodes.
@export var flagHolder:Control

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Used to get and set the flags used by all generated [DC_StoryFlagFieldOption] nodes, as well as the flags' state.
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var flagHandler:DC_AspectsFlags = # a pre-configured node from the scene tree
##
## # Get the current configured flags
## print(flagHandler.currentFlags)  # output: {"testFlag": false}
## 
## # Set the state of some configured flags
## optionNode.currentFlags = {"testFlag": true}
## [/codeblock]
var currentFlags:Dictionary:
	set(newFlags):
		for flag in newFlags.keys():
			_createStoryFlagSection()
			_currentFlagFields.back().flagID = flag
			_currentFlagFields.back().enabled = newFlags[flag]
	get():
		return _getFields()

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  A reference to a [DC_StoryFlagFieldOption] scene.
var _storyFlagScene:Resource

## [b]Internal-use only.[/b]  Used to keep track of any flags not configured.
var _unusedFlags:Array[String]
## [b]Internal-use only.[/b]  Used to keep track of all configured flags.
var _usedFlags:Array[String]
## [b]Internal-use only.[/b]  Used to keep track of all generated field scenes.
var _currentFlagFields:Array[DC_StoryFlagFieldOption]

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	var keys:Array = StoryFlags.default_flags.keys()
	var typingMoment:Array[String]
	for key in keys:
		typingMoment.push_back(key as String)
	_unusedFlags = typingMoment

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Retrieves the values of each generated [DC_StoryFlagFieldOption] field.
func _getFields() -> Dictionary:
	var result:Dictionary = {}
	for field in _currentFlagFields:
		result.set(field.flagID, field.enabled)
	return result

## [b]Internal-use only.[/b]  Find the first unused [member StoryFlag.default_flags] in-order.
func _getUnusedStoryFlag() -> String:
	for flag in StoryFlags.default_flags.keys():
		if flag not in _usedFlags:
			return flag
			
	print("SetFlags: All flags have been added.")
	return ""

## [b]Internal-use only.[/b]  Creates and configures a [DC_StoryFlagFieldOption]
## field for the first unused [member StoryFlag.default_flags] flag.
func _createStoryFlagSection() -> void:
	var flagID:String = _getUnusedStoryFlag()
	if flagID == "":
		return
	
	# create the nodes
	var newFlag:DC_StoryFlagFieldOption = _storyFlagScene.instantiate()
	var separator:VSeparator = VSeparator.new()
	flagHolder.add_child(separator)
	flagHolder.add_child(newFlag)
	_currentFlagFields.push_back(newFlag)
	
	# configure
	update_available_flags.connect(newFlag._on_update_available_flags)
	newFlag._on_update_available_flags(_unusedFlags)
	await get_tree().process_frame  # let flag field get ready
	
	newFlag.flagID = flagID
	_usedFlags.push_back(flagID)
	_updateUnusedFlags()
	newFlag.separator = separator
	newFlag.removing.connect(_on_flag_field_removed)
	newFlag.option_changed_history.connect(_on_flag_field_updated)

## [b]Internal-use only.[/b]  Updates the possible choices for every currently
## created [DC_StoryFlagFieldOption] field.
func _updateUnusedFlags() -> void:
	var daCopy:Array = StoryFlags.default_flags.keys()
	for used in _usedFlags:
		daCopy.erase(used)
	var typingMoment:Array[String] = []
	for copy in daCopy:
		typingMoment.push_back(copy)
		
	_unusedFlags = typingMoment
	update_available_flags.emit(_unusedFlags)
	value_changed.emit()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when the add button is pressed.
## Can also be used to "simulate" the button being pressed with code.
func _on_add_button_pressed() -> void:
	_createStoryFlagSection()
	value_changed.emit()

## [b]Internal-use only.[/b]  Runs when a [DC_StoryFlagFieldOption] field is being removed.
func _on_flag_field_removed(field:DC_StoryFlagFieldOption) -> void:
	_currentFlagFields.erase(field)
	_usedFlags.erase(field.flagID)
	_updateUnusedFlags()

## [b]Internal-use only.[/b]  Runs when a [DC_StoryFlagFieldOption]'s chosen flag gets updated.
func _on_flag_field_updated(oldFlagID:String, newFlagID:String) -> void:
	_usedFlags.erase(oldFlagID)
	_usedFlags.push_back(newFlagID)
	_updateUnusedFlags()
	value_changed.emit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
