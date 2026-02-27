extends DC_BaseObject
class_name DC_DialogueOption

signal values_updated(port:int, newValues:Dictionary)
signal disconnect_dialogue(port:int)

@export var textField:TextEdit

@onready var closeButton:PackedScene = preload("uid://ccer37a12iyow")

var port:int = -1
var text:String:
	set(value):
		text = value
		if not textUpdateFromField:
			textField.text = value
			textUpdateFromField = true
		values_updated.emit(port, getFields())
var textUpdateFromField:bool = true
var nextID:String = ""

func _ready() -> void:
	createCloseButton()
	
	set_slot_color_left(0, PORT_COLOR.OPTION)
	set_slot_color_right(1, PORT_COLOR.DIALOGUE)

func createCloseButton() -> void:
	var close:Button = closeButton.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

func getFields() -> Dictionary:
	var currentValues:Dictionary = {
		"text": textField.text
	}
	
	if nextID != "":
		currentValues["nextID"] = nextID

	return currentValues

func dialogueDisconnected() -> void:
	port = -1

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

func _on_debug_pressed() -> void:
	print("Port: ", port)
	print("nextID: ", nextID)

func _on_close_button_pressed() -> void:
	print("eggs")
	super()
