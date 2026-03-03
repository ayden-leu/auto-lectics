extends DC_BaseObject
class_name DC_DialogueObject

signal id_updated(newID:String)
signal disconnect_id()
signal disconnect_option(port:int)
signal disconnect_all_options
signal save_me(data:Dictionary)
signal disconnect_hectic_port(port:int)
signal reconnect_hectic_port(port:int)
## For internal use.  Do not use.
signal _option_amount_changed()

@export var dialogueIDField:LineEdit
@export var textField:TextEdit
@export var typeField:OptionButton
@export var modeField:OptionButton
@export var writeSpeedAspectsHandler:Control

@onready var optionLabelScene:PackedScene = preload("uid://cjuc58ngbb0lm")

const numNodesAboveOptions:int = 3
const dialogueIDPort:int = 0

var id:String:
	set(value):
		id = value
		if not idUpdateFromField:
			dialogueIDField.text = value
			idUpdateFromField = true
		title = "Dialogue: " + value
		id_updated.emit(value)
var idUpdateFromField:bool = true
var text:String:
	set(value):
		text = value
		textField.text = value
var options:Array[Dictionary] = []
var optionPorts:Array[Label] = []
var numOptions:int = 0:
	set(value):
		if value >= 0:
			numOptions = value
var nextOnHecticFailId:String = ""
var nextOnHecticPortEnabled:bool = false

func _ready() -> void:
	createCloseButton()
	
	set_slot_color_left(dialogueIDPort, PORT_COLOR.DIALOGUE)
	set_slot_type_left(dialogueIDPort, PORT_TYPE.DIALOGUE)

func createCloseButton() -> void:
	var close:Button = closeButtonScene.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

func createOptionPort() -> void:
	var optionLabel:Label = optionLabelScene.instantiate()
	optionPorts.push_back(optionLabel)
	
	add_child(optionLabel)
	move_child(optionLabel, numNodesAboveOptions + numOptions)
	optionLabel.text = str(numOptions)
	optionLabel.theme_type_variation = "LabelOption"
	
	if nextOnHecticPortEnabled:
		shiftHecticPort(1)
	
	set_slot(numNodesAboveOptions + numOptions,
		false, 0, Color.TRANSPARENT,
		true, PORT_TYPE.OPTION, PORT_COLOR.OPTION
	)
	options.push_back({})
	numOptions += 1
	
	_option_amount_changed.emit()

func removeOptionPort() -> void:
	if nextOnHecticPortEnabled:
		shiftHecticPort(-1)
	
	numOptions -= 1	
	var toRemove:Label = optionPorts.pop_back()
	clear_slot(numNodesAboveOptions + numOptions)
	options.pop_back()
	toRemove.queue_free()
	
	disconnect_option.emit(numOptions)
	
	_option_amount_changed.emit()

func shiftHecticPort(amount:int) -> void:
	var currentSlot:int = numNodesAboveOptions + numOptions
	
	disconnect_hectic_port.emit(numOptions)
	set_slot(currentSlot,
		false, 0, Color.TRANSPARENT,
		false, 0, Color.TRANSPARENT
	)
	
	await _option_amount_changed
	
	set_slot(currentSlot + amount,
		false, 0, Color.TRANSPARENT,
		true, PORT_TYPE.DIALOGUE, PORT_COLOR.DIALOGUE
	)

func getFields() -> Dictionary:
	var currentValues:Dictionary = {
		"id": dialogueIDField.text,
		"text": textField.text,
		#"font": "",
		"type": DialogueDefaults.OPTION_TYPES[typeField.selected],
		"mode": DialogueDefaults.DIALOGUE_MODES[modeField.selected]
	}
	
	#if font != "":  # not used yet
		#currentValues.font = font
	
	if currentValues.mode == "hectic" and nextOnHecticFailId == "":
		# TODO:  make the warning pop up on screen
		printerr("Next On Hectic Fail not set!")
	
	if writeSpeedAspectsHandler.getPreset() != DialogueDefaults.defaultDialogue.writeSpeed:
		currentValues.writeSpeed = writeSpeedAspectsHandler.getPreset()
		if currentValues.writeSpeed == "custom":
			currentValues.writeSpeedCustom = writeSpeedAspectsHandler.getValue()
	
	if options != []:
		var optionsToAdd:Array[Dictionary] = []
		for option in options:
			if option == {}:
				continue
			optionsToAdd.push_back(option)
		
		if optionsToAdd != []:
			currentValues.options = optionsToAdd
	
	return currentValues

func saveToFile() -> void:
	var data:Dictionary = getFields()
		
	if data.id == "":
		printerr("DC_DialogueObject/saveToFile(): Dialogue Object ID not set.")
	
	save_me.emit(data)

func optionDisconnected(port:int) -> void:
	options[port] = {}

func nextOnHecticFailIdDisconnected() -> void:
	nextOnHecticFailId = ""

func delete() -> void:
	disconnect_all_options.emit()
	disconnect_id.emit()
	super()

# ---------------------------

func _on_dialogue_id_updated(newID:String) -> void:
	idUpdateFromField = true
	id = newID

func _on_save_pressed() -> void:
	saveToFile()

func _on_add_option_pressed() -> void:
	createOptionPort()

func _on_remove_option_pressed() -> void:
	removeOptionPort()

func _on_option_updated(index:int, newValue:Dictionary) -> void:
	options[index] = newValue

func _on_set_hectic_port(on: bool) -> void:
	if not on:
		disconnect_hectic_port.emit(numOptions)
	
	set_slot(numNodesAboveOptions + numOptions,
		false, 0, Color.TRANSPARENT,
		on, PORT_TYPE.DIALOGUE, PORT_COLOR.DIALOGUE
	)
	nextOnHecticPortEnabled = on
	

func _on_hectic_fail_updated(newID:String) -> void:
	nextOnHecticFailId = newID

func _on_debug_pressed() -> void:
	print("------ ", title, " ------")
	print("Text: ", text)
	print("Options: ", options)
	print("OptionPorts: ", optionPorts)
	print("numOptions: ", numOptions)
	print("Type: ", DialogueDefaults.OPTION_TYPES[typeField.selected])
	print("Mode: ", DialogueDefaults.DIALOGUE_MODES[modeField.selected])
	print("Next On Hectic Fail: ", nextOnHecticFailId)
