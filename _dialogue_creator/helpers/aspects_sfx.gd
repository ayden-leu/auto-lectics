extends VBoxContainer
class_name DC_AspectsSfx

@export var toggler:DC_SectionToggle
@export var eventHolder:Control

const sfxEventScene:Resource = preload("uid://citmsrjh10i13")

var sfxEventFieldOptions:Dictionary[String, DC_SfxEventFieldOption] = {}

var aspects:Dictionary:
	set(newAspects):
		var keys:Array = newAspects.keys()
		var values:Array = newAspects.values()
		for i in range(keys.size()):
			sfxEventFieldOptions[keys[i]].option = values[i]
	get():
		return getAspects()

func _ready() -> void:
	for event in DialogueDefaults.SFX_EVENTS:
		createEventSection(event)

func createEventSection(eventName:String) -> void:
	var newEvent:DC_SfxEventFieldOption = sfxEventScene.instantiate()
	newEvent.eventID = eventName
	
	eventHolder.add_child(VSeparator.new())
	eventHolder.add_child(newEvent)
	sfxEventFieldOptions[eventName] = newEvent

func getAspects() -> Dictionary:
	var all:Dictionary = {}
	for eventFieldOption:DC_SfxEventFieldOption in sfxEventFieldOptions.values():
		if eventFieldOption.option != "none":
			all[eventFieldOption.eventID] = eventFieldOption.option
	return all
