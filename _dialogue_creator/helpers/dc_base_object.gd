extends GraphNode
class_name DC_BaseNode
## The base class used for custom nodes for the [DialogueCreator]. This should only be extended by other classes/scripts.

## Emitted when this wants to disconnect all connections it currently has.
signal disconnect_all(node:DC_BaseNode)
## Emitted when this plans on deleting itself.
signal deleting(node:DC_BaseNode)

@onready var _closeButtonScene:PackedScene = preload("uid://ccer37a12iyow")

## The types of ports that can be setup.
enum PORT_TYPE {
	OPTION,
	DIALOGUE
}
## The color for the various ports that can be setup.
const PORT_COLOR:Dictionary = {
	OPTION = Color("d9543d"),
	DIALOGUE = Color("00b5b5")
}

func _ready() -> void:
	_createCloseButton()

func _createCloseButton() -> void:
	var close:Button = _closeButtonScene.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

## Deletes this node.
func delete() -> void:
	deleting.emit(self)
	queue_free()

func _on_close_button_pressed() -> void:
	disconnect_all.emit(self)
	self.delete()

func _on_resize_height() -> void:
	size.y = get_minimum_size().y

func _on_toggle_visibility(isVisible:bool) -> void:
	visible = isVisible
