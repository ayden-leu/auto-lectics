extends VBoxContainer
class_name DC_SfxAspects

@export var toggler:DC_SectionToggle
@export var eventHolder:Control

const sfxEventScene:Resource = preload("uid://citmsrjh10i13")

func _ready() -> void:
	for event in DialogueDefaults.SFX_EVENTS:
		createEventSection(event)

func createEventSection(eventName:String) -> void:
	var newEvent:DC_SfxEvent = sfxEventScene.instantiate()
	newEvent.eventID = eventName
	
	eventHolder.add_child(VSeparator.new())
	eventHolder.add_child(newEvent)

func getAspects() -> Dictionary:
	var all:Dictionary = {}
	for event:DC_SfxEvent in eventHolder.get_children():
		var chosen:String = event.getChosenOption()
		if chosen != "":
			all[event.eventID] = event.getChosenOption()
	
	return all
