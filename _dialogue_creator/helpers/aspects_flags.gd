extends VBoxContainer
class_name DC_AspectsFlags

signal value_changed()
signal update_available_flags()

@export var flagHolder:VBoxContainer

var _storyFlagScene:Resource

var _unusedFlags:Array
var _usedFlags:Array[String]
var _currentFlagFields:Array[DC_StoryFlagFieldOption]
var currentFlags:Dictionary:
	set(newFlags):
		for flag in newFlags.keys():
			_createStoryFlagSection()
			_currentFlagFields.back().flagID = flag
			_currentFlagFields.back().enabled = newFlags[flag]
	get():
		return _getFields()

func _ready() -> void:
	_unusedFlags = StoryFlags.default_flags.keys()

func _getFields() -> Dictionary:
	var result:Dictionary = {}
	for field in _currentFlagFields:
		result.set(field.flagID, field.enabled)
	return result

func _getUnusedStoryFlag() -> String:
	for flag in StoryFlags.default_flags.keys():
		if flag not in _usedFlags:
			return flag
			
	printerr("SetFlags: All flags have been added.")
	return ""

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
	newFlag.mySeparator = separator
	newFlag.removing.connect(_on_flag_field_removed)
	newFlag.updating.connect(_on_flag_field_updated)
	newFlag.option_changed.connect(_on_option_changed)

func _updateUnusedFlags() -> void:
	var daCopy:Array = StoryFlags.default_flags.keys()
	for used in _usedFlags:
		daCopy.erase(used)
	_unusedFlags = daCopy
	update_available_flags.emit(_unusedFlags)
	value_changed.emit()

func _on_add_button_pressed() -> void:
	_createStoryFlagSection()
	value_changed.emit()

func _on_flag_field_removed(field:DC_StoryFlagFieldOption) -> void:
	_currentFlagFields.erase(field)
	_usedFlags.erase(field.flagID)
	_updateUnusedFlags()

func _on_flag_field_updated(oldFlagID:String, newFlagID:String) -> void:
	_usedFlags.erase(oldFlagID)
	_usedFlags.push_back(newFlagID)
	_updateUnusedFlags()

func _on_option_changed() -> void:
	value_changed.emit()
