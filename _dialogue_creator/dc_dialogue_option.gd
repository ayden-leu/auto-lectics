extends DC_BaseObject
class_name DC_DialogueOption

signal values_updated(port:int, newValues:Dictionary)
signal disconnect_dialogue(port:int)

@export var textField:TextEdit
@export var typeField:DC_TypeFieldOption
@export var writeSpeedAspectsHandler:DC_AspectsWriteSpeed
@export var sfxEventAspectsHandler:DC_AspectsSfx
@export var spawnDelayField:SpinBox
@export var lifetimeField:SpinBox

@onready var closeButton:PackedScene = preload("uid://ccer37a12iyow")

const optionPort:int = 0
const nextIDPort:int = 0

var port:int = -1
var text:String:
	set(value):
		if not textUpdateFromField:
			textField.text = value
			textUpdateFromField = true
		_on_attribute_modified()
	get():
		return textField.text
var textUpdateFromField:bool = true
var type:String:
	set(newType):
		typeField.option = newType
		_on_attribute_modified()
	get():
		return typeField.option
var sfxEventAspects:Dictionary:
	set(newSfxEventAspects):
		sfxEventAspectsHandler.aspects = newSfxEventAspects
		_on_attribute_modified()
	get():
		return sfxEventAspectsHandler.aspects
var writeSpeedPreset:String:
	set(newPreset):
		writeSpeedAspectsHandler.preset = newPreset
		_on_attribute_modified()
	get():
		return writeSpeedAspectsHandler.preset
var writeSpeedValue:float:
	set(newSpeed):
		writeSpeedAspectsHandler.value = newSpeed
		_on_attribute_modified()
	get():
		return writeSpeedAspectsHandler.value

var spawnDelay:float:
	set(newDelay):
		spawnDelayField.value = newDelay
		_on_attribute_modified()
	get():
		return spawnDelayField.value
var lifetime:float:
	set(newLife):
		lifetimeField.value = newLife
		_on_attribute_modified()
	get():
		return lifetimeField.value
var nextID:String = ""

func _ready() -> void:
	super()
	set_slot_color_left(0, PORT_COLOR.OPTION)
	set_slot_type_left(0, PORT_TYPE.OPTION)
	
	set_slot_color_right(1, PORT_COLOR.DIALOGUE)
	set_slot_type_right(1, PORT_TYPE.DIALOGUE)
	
	sfxEventAspects = DialogueDefaults.defaultOption.sfx
	spawnDelay = DialogueDefaults.defaultOption.spawnDelay
	lifetime = DialogueDefaults.defaultOption.lifetime

func getFields() -> Dictionary:
	var currentValues:Dictionary = {
		"text": textField.text
	}
	
	# font (unused atm)
	
	currentValues.type = type
	
	if writeSpeedPreset != DialogueDefaults.defaultDialogue.writeSpeed:
		currentValues.writeSpeed = writeSpeedPreset
		if currentValues.writeSpeed == "custom":
			currentValues.writeSpeedCustom = writeSpeedAspectsHandler.value
	
	if sfxEventAspects != {}:
		currentValues.sfx = sfxEventAspects
	
	# background theme (unused atm)
	# particles (unused atm)
	
	if spawnDelay != DialogueDefaults.defaultOption.spawnDelay:
		currentValues.spawnDelay = spawnDelay
	
	if lifetime != DialogueDefaults.defaultOption.lifetime:
		currentValues.lifetime = lifetime
	
	if nextID != "":
		currentValues.nextID = nextID

	return currentValues

func dialogueDisconnected() -> void:
	port = -1
	nextID = ""

func delete() -> void:
	disconnect_dialogue.emit(port)
	super()

# -----------------

func _on_attribute_modified() -> void:
	#print("option modified, emitting")
	values_updated.emit(port, getFields())

func _on_text_field_updated() -> void:
	textUpdateFromField = true
	_on_attribute_modified()

func _on_next_object_id_modified(newID:String) -> void:
	nextID = newID
	_on_attribute_modified()

func _on_debug_pressed() -> void:
	print("------ Dialogue Option ------")
	print("Port: ", port)
	print("Text: ", text)
	print("Type: ", typeField.option)
	
	if writeSpeedAspectsHandler.preset != DialogueDefaults.defaultDialogue.writeSpeed:
		print("Write Speed Preset: ", writeSpeedAspectsHandler.preset)
		print("Write Speed Value: ", writeSpeedAspectsHandler.value)
	
	var aspects:Dictionary = sfxEventAspectsHandler.aspects
	if aspects != {}:
		print("SFX Aspects:")
		for event in aspects:
			print("\t", event, ": ", aspects[event])
	
	print("spawnDelay: ", spawnDelay)
	print("lifetime: ", lifetime)
	print("nextID: ", nextID)
