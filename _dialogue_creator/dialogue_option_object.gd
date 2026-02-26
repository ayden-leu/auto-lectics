extends DC_Object
class_name DC_DialogueOptionObject

signal values_updated(port:int, newValues:Dictionary)
signal disconnect_left(port:int)

@export var textField:TextEdit
@export var nextIDField:LineEdit

@onready var closeButton:PackedScene = preload("uid://ccer37a12iyow")

var port:int = -1

func _ready() -> void:
	createCloseButton()
	createSlots()

func createCloseButton() -> void:
	var close:Button = closeButton.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

func createSlots() -> void:
	set_slot(0,
		true, PORT_TYPE.OPTION, Color.WEB_MAROON,
		false, 0, Color.TRANSPARENT
	)

func getFields() -> Dictionary:
	var currentValues:Dictionary = {
		"text": textField.text,
		"nextID": nextIDField.text
	}

	return currentValues

func leftPortDisconnected() -> void:
	port = -1

func delete() -> void:
	disconnect_left.emit(port)
	super()

# -----------------

func _on_attribute_modified() -> void:
	#print("option modified, emitting")
	values_updated.emit(port, getFields())

func _on_next_id_modified(_newValue:String) -> void:
	_on_attribute_modified()
	
func _on_debug_pressed() -> void:
	print("Port: ", port)
