extends DC_BaseObject
class_name DC_DialogueObject

signal id_updated(newID:String)
signal disconnect_option(port:int)
signal disconnect_all_options
signal save_me(data:Dictionary)

@export var dialogueIDField:LineEdit
@export var textField:TextEdit

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
	
	set_slot(numNodesAboveOptions + numOptions,
		false, 0, Color.TRANSPARENT,
		true, PORT_TYPE.OPTION, PORT_COLOR.OPTION
	)
	options.push_back({})
	numOptions += 1

func removeSlot() -> void:
	numOptions -= 1	
	var toRemove:Label = optionPorts.pop_back()
	clear_slot(numNodesAboveOptions + numOptions)
	options.pop_back()
	toRemove.queue_free()
	
	disconnect_option.emit(numOptions)

func getFields() -> Dictionary:
	var currentValues:Dictionary = {
		"id": dialogueIDField.text,
		"text": textField.text
	}
	
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

func delete() -> void:
	disconnect_all_options.emit()
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
	removeSlot()

func _on_option_updated(index:int, newValue:Dictionary) -> void:
	options[index] = newValue

func _on_debug_pressed() -> void:
	print("------ ", title, " ------")
	print("Text:", text)
	print("Options: ", options)
	print("OptionPorts: ", optionPorts)
	print("numOptions: ", numOptions)
