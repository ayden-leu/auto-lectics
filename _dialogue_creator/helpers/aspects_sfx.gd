extends VBoxContainer
class_name DC_AspectsSfx
## Manages the possible SFX events you can configure for [DC_DialogueNode] and [DC_OptionNode].

signal value_changed()

## Holds all SFX Event configuration fields that are created.
@export var eventHolder:Control

const _sfxEventScene:Resource = preload("uid://citmsrjh10i13")

var _sfxEventFieldOptions:Dictionary[String, DC_SfxEventFieldOption] = {}

## Used to get and set the chosen SFX ID for all possible SFX events.
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## When getting, if a field matches its corresponding field in [member DialogueDefaults.defaultDialogue] or [member DialogueDefaults.defaultOption], it will not be included.
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

func _ready() -> void:
	for event in DialogueDefaults.SFX_EVENTS:
		_createEventSection(event)

func _createEventSection(eventName:String) -> void:
	var newEvent:DC_SfxEventFieldOption = _sfxEventScene.instantiate()
	newEvent.eventID = eventName
	
	eventHolder.add_child(VSeparator.new())
	eventHolder.add_child(newEvent)
	_sfxEventFieldOptions[eventName] = newEvent
	newEvent.option_changed.connect(_on_field_updated)

func _getAspects() -> Dictionary:
	var all:Dictionary = {}
	for eventFieldOption:DC_SfxEventFieldOption in _sfxEventFieldOptions.values():
		if eventFieldOption.option != "none":
			all[eventFieldOption.eventID] = eventFieldOption.option
	return all

func _on_field_updated() -> void:
	value_changed.emit()
