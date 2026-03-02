extends OptionButton

signal set_hectic_port(on:bool)

@export var hecticPortLabel:Label

func _ready() -> void:
	hecticPortLabel.visible = false

func _on_item_selected(index: int) -> void:
	var isHectic:bool = DialogueDefaults.DIALOGUE_MODES[index] == "hectic"
	
	hecticPortLabel.visible = isHectic
	set_hectic_port.emit(isHectic)
