extends DC_Object
class_name DC_DialogueObject

signal id_updated(newID:String)
signal disconnect_right(port:int)
signal disconnect_all_right

@export var dialogueIDField:LineEdit
@export var textField:TextEdit

@onready var optionLabelScene:PackedScene = preload("uid://cjuc58ngbb0lm")

const numNodesAboveOptions:int = 3

var options:Array[Dictionary] = []
var optionPorts:Array[Label] = []
var numOptions:int = 0:
	set(value):
		if value >= 0:
			numOptions = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createCloseButton()

func createCloseButton() -> void:
	var close:Button = closeButtonScene.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

func createSlot() -> void:
	var optionLabel:Label = optionLabelScene.instantiate()
	optionLabel.text = str(numOptions)
	add_child(optionLabel)
	move_child(optionLabel, numNodesAboveOptions + numOptions)
	optionPorts.push_back(optionLabel)
	
	set_slot(numNodesAboveOptions + numOptions,
		false, 0, Color.TRANSPARENT,
		true, PORT_TYPE.OPTION, Color.WEB_MAROON
	)
	options.push_back({})
	numOptions += 1

func removeSlot() -> void:
	numOptions -= 1	
	var toRemove:Label = optionPorts.pop_back()
	clear_slot(numNodesAboveOptions + numOptions)
	options.pop_back()
	toRemove.queue_free()
	
	disconnect_right.emit(numOptions)

func getFields() -> Dictionary:
	var currentValues:Dictionary = {
		"id": dialogueIDField.text,
		"text": textField.text,
		"options": options
	}
	
	return currentValues

func rightPortDisconnected(port:int) -> void:
	options[port] = {}

func delete() -> void:
	disconnect_all_right.emit()
	super()

# ---------------------------

func _on_dialogue_id_updated(newID:String) -> void:
	title = "Dialogue: " + newID
	id_updated.emit(newID)

func _on_add_option_pressed() -> void:
	createSlot()

func _on_remove_option_pressed() -> void:
	removeSlot()

func _on_option_updated(index:int, newValue:Dictionary) -> void:
	options[index] = newValue

func _on_debug_pressed() -> void:
	print("Options: ", options)
	print("OptionPorts: ", optionPorts)
	print("numOptions: ", numOptions)
