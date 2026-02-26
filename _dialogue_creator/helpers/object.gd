extends GraphNode
class_name DC_Object

signal disconnect_all(node:DC_Object)

@onready var closeButtonScene:PackedScene = preload("uid://ccer37a12iyow")

enum PORT_TYPE{
	OPTION,
	DIALOGUE
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createCloseButton()

func createCloseButton() -> void:
	var close:Button = closeButtonScene.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

func delete() -> void:
	queue_free()

# ---------------------------

func _on_close_button_pressed() -> void:
	disconnect_all.emit(self)
	self.delete()
