extends GraphNode
class_name DC_BaseObject

signal disconnect_all(node:DC_BaseObject)
signal deleting(node:DC_BaseObject)

@onready var closeButtonScene:PackedScene = preload("uid://ccer37a12iyow")

enum PORT_TYPE{
	OPTION,
	DIALOGUE
}
const PORT_COLOR:Dictionary = {
	OPTION = Color("d9543d"),
	DIALOGUE = Color("00b5b5")
}

func _ready() -> void:
	createCloseButton()

func createCloseButton() -> void:
	var close:Button = closeButtonScene.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

func delete() -> void:
	deleting.emit(self)
	queue_free()

# ---------------------------

func _on_close_button_pressed() -> void:
	disconnect_all.emit(self)
	self.delete()

func _on_resize_height() -> void:
	size.y = get_minimum_size().y
