extends GraphNode

@onready var closeButton:PackedScene = preload("uid://ccer37a12iyow")

var options:Array = []

enum PORT_TYPE{
	OPTION,
	DIALOGUE
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createCloseButton()
	createSlots()

func createCloseButton() -> void:
	var close:Button = closeButton.instantiate()
	get_titlebar_hbox().add_child(close)
	close.pressed.connect(_on_close_button_pressed)

func createSlots() -> void:
	# Options
	set_slot(0,
		false, 0, Color.TRANSPARENT,
		true, PORT_TYPE.OPTION, Color.WEB_MAROON
	)

func _on_close_button_pressed() -> void:
	queue_free()

func _on_dialogue_id_updated(newID:String) -> void:
	title = "Dialogue: " + newID
