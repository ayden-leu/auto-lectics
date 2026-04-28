extends VBoxContainer
class_name DC_AspectsSfx
## [b]Internal-use only.[/b]  Manages the possible SFX events you can configure for [DC_DialogueNode] and [DC_OptionNode].
## All SFX events can be found in [member DialogueDefaults.SFX_EVENTS].

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted whenever the value of a [DC_SfxEventFieldOption] field gets updated.
signal value_changed()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]  A reference to the [DC_SfxEventFieldOption] scene.
const _SFX_EVENT_SCENE:Resource = preload("uid://citmsrjh10i13")

# ------------------------------------------------
# export variables
# ------------------------------------------------
## Holds all [DC_SfxEventFieldOption] fields that are created.
@export var eventHolder:Control

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Used to get and set the SFX ID for all possible [member DialogueDefaults.SFX_EVENTS].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## [br][br]
## Usage:
## [codeblock]
## var sfxEventAspectsHandler:DC_AspectsSfx = # a pre-configured node from the scene tree
##
## # Get the currently set SFX events
## print(sfxEventAspectsHandler.aspects)  # output: {"eventId1": "sfxId1", "eventId2": "sfxId2"}
## 
## # Set the SFX IDs of some SFX events
## sfxEventAspectsHandler.aspects = {
## 	"eventId1": "sfxId1",
## 	"eventId2": "sfxId2"
## }
## [/codeblock]
var aspects:Dictionary:
	set(newAspects):
		var keys:Array = newAspects.keys()
		var values:Array = newAspects.values()
		for i in range(keys.size()):
			_sfxEventFieldOptions[keys[i]].option = values[i]
	get():
		return _getAspects()

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Holds all generated [DC_SfxEventFieldOption] fields
## and matches them to their corresponding [member DialogueDefaults.SFX_EVENTS] ID.
var _sfxEventFieldOptions:Dictionary[String, DC_SfxEventFieldOption] = {}

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	for event in DialogueDefaults.SFX_EVENTS:
		_createEventSection(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Creates a [DC_SfxEventFieldOption] field for a given event name.
func _createEventSection(eventName:String) -> void:
	if _sfxEventFieldOptions.has(eventName):
		printerr("AspectsSFX:  Field for [", eventName, "] already exists.")
		return
	
	var newEvent:DC_SfxEventFieldOption = _SFX_EVENT_SCENE.instantiate()
	newEvent.eventID = eventName
	
	eventHolder.add_child(VSeparator.new())
	eventHolder.add_child(newEvent)
	_sfxEventFieldOptions[eventName] = newEvent
	newEvent.option_changed.connect(_on_field_updated)

## [b]Internal-use only.[/b]  Retrieves the values of each generated [DC_SfxEventFieldOption] field.
func _getAspects() -> Dictionary:
	var all:Dictionary = {}
	for eventFieldOption:DC_SfxEventFieldOption in _sfxEventFieldOptions.values():
		if eventFieldOption.option != "none":
			all[eventFieldOption.eventID] = eventFieldOption.option
	return all

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Runs when a [DC_SfxEventFieldOption]'s chosen SFX ID gets updated.
func _on_field_updated() -> void:
	value_changed.emit()
	
# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
