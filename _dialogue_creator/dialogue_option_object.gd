extends GraphNode

signal next_id_updated(nextID:String)

@onready var closeButton:PackedScene = preload("uid://ccer37a12iyow")

enum PORT_TYPE{
	OPTION,
	DIALOGUE
}

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

func _on_close_button_pressed() -> void:
	queue_free()
