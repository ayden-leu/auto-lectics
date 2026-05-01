extends VBoxContainer
class_name DC_FlagAspects
## [b]Internal-use only.[/b]  Used to handle any configured [StoryFlags] for [DC_DialogueNode] and [DC_OptionNode].

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when any field managed by this node is modified.
signal value_changed()
## Emitted when a [member StoryFlags.DEFAULT_FLAGS] flag is being used by a [DC_StoryFlagChooser].
signal update_available_flags()
## Emitted when the node this field belongs to should resize itself.
signal resize()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The node that holds generated [DC_StoryFlagChooser] nodes.
@export var flagHolder:Control

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The StoryFlags that are currently configured.
## Setting this will update other nodes appropriately.
## [br][br]
## Dictionary format is the following:
## [codeblock]
## var dict:Dictionary = {
## 	"flagName": true  # or false
## }
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
## [b]Internal-use only.[/b]  A reference to a [DC_StoryFlagChooser] scene.
var _storyFlagScene:Resource

## [b]Internal-use only.[/b]  Used to keep track of any flags not configured.
var _unusedFlags:Array[String]
## [b]Internal-use only.[/b]  Used to keep track of all configured flags.
var _usedFlags:Array[String]
## [b]Internal-use only.[/b]  Used to keep track of all generated field scenes.
var _currentFlagFields:Array[DC_StoryFlagChooser]

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	var keys:Array = StoryFlags.DEFAULT_FLAGS.keys()
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
## [b]Internal-use only.[/b]  Retrieves the values of each generated [DC_StoryFlagChooser] field.
func _getFields() -> Dictionary:
	var result:Dictionary = {}
	for field in _currentFlagFields:
		result.set(field.flagID, field.enabled)
	return result

## [b]Internal-use only.[/b]  Find the first unused [member StoryFlag.DEFAULT_FLAGS] in-order.
func _getUnusedStoryFlag() -> String:
	for flag in StoryFlags.DEFAULT_FLAGS.keys():
		if flag not in _usedFlags:
			return flag
			
	print("SetFlags: All flags have been added.")
	return ""

## [b]Internal-use only.[/b]  Creates and configures a [DC_StoryFlagChooser]
## field for the first unused [member StoryFlag.DEFAULT_FLAGS] flag.
func _createStoryFlagSection() -> void:
	var flagID:String = _getUnusedStoryFlag()
	if flagID == "":
		return
	
	# create the nodes
	var newFlag:DC_StoryFlagChooser = _storyFlagScene.instantiate()
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
	newFlag.field_updated_history.connect(_on_flag_field_updated)
	newFlag.field_updated.connect(_on_flag_field_state_updated)

## [b]Internal-use only.[/b]  Updates the possible choices for every currently
## created [DC_StoryFlagChooser] field.
func _updateUnusedFlags() -> void:
	var daCopy:Array = StoryFlags.DEFAULT_FLAGS.keys()
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

## [b]Internal-use only.[/b]  Runs when a [DC_StoryFlagChooser] field is being removed.
func _on_flag_field_removed(field:DC_StoryFlagChooser) -> void:
	_currentFlagFields.erase(field)
	_usedFlags.erase(field.flagID)
	_updateUnusedFlags()
	await get_tree().process_frame
	await get_tree().process_frame
	resize.emit()

## [b]Internal-use only.[/b]  Runs when a [DC_StoryFlagChooser]'s chosen flag gets updated.
func _on_flag_field_updated(oldFlagID:String, newFlagID:String) -> void:
	_usedFlags.erase(oldFlagID)
	_usedFlags.push_back(newFlagID)
	_updateUnusedFlags()
	value_changed.emit()

## [b]Internal-use only.[/b]  Runs when a [DC_StoryFlagChooser]'s flag state gets updated.
func _on_flag_field_state_updated() -> void:
	value_changed.emit()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
