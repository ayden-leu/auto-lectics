extends GraphNode
class_name DC_BaseNode
## The base class used for custom nodes for the [DialogueCreator]. This should only be extended by other classes/scripts.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this wants to disconnect all connections it currently has.
signal disconnect_all(node:DC_BaseNode)
## Emitted when this plans on deleting itself.
signal deleting(node:DC_BaseNode)

# ------------------------------------------------
# enums
# ------------------------------------------------
## The types of ports that can be setup.
enum PortType {
	OPTION,
	DIALOGUE
}

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The scene that holds the close button.
## Used due to not being able to add stuff to a [GraphNode] header in the node layout.
const _CLOSE_BUTTON_SCENE:PackedScene = preload("uid://ccer37a12iyow")

## The color for the various ports that can be setup.
## It's named like an enum cause its used like an enum.
const PortColor:Dictionary[StringName, Color] = {
	OPTION = Color("d9543d"),
	DIALOGUE = Color("00b5b5")
}

## [b]Internal-use only.[/b]
## The value that represents the actual value being in the default attribute
## file for this [InteractaleNPC].
const _CHECK_NPC_DEFAULT_VALUE:String = "npcDefault"
## [b]Internal-use only.[/b]
## The value that represents the actual value being in the default attribute
## file for this [InteractaleNPC].
const _CHECK_NPC_DEFAULT_VALUE_NUM:float = -0.1

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_createCloseButton()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------


# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## Makes this node's height the smallest it can be.
func _shrinkNodeHeight() -> void:
	size.y = get_minimum_size().y

## [b]Internal-use only.[/b]  Creates and adds a close button in the header.
func _createCloseButton() -> void:
	var close:Button = _CLOSE_BUTTON_SCENE.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

## Deletes this node.
func _delete() -> void:
	deleting.emit(self)
	queue_free()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Runs when the close button is pressed.
## Can also be used to "simulate" the button being pressed with code.
func _on_close_button_pressed() -> void:
	disconnect_all.emit(self)
	_delete()

## [b]Internal-use only.[/b]
## Typically runs whenever fields are hidden.
func _on_resize_height() -> void:
	_shrinkNodeHeight()

## [b]Internal-use only.[/b]
## Runs when this node should be hidden.
func _on_toggle_visibility(isVisible:bool) -> void:
	visible = isVisible

## [b]Internal-use only.[/b]
## Handles logic for when a field is updated.
func _on_field_updated() -> void:
	_shrinkNodeHeight()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
