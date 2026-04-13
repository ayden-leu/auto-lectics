extends Control

signal selected(npc_id: String)

@export var npc_id: String = "npc_test"
@export var locked_display_text: String = "???"

@onready var icon_button = $EntryLayout/TextureButton
@onready var name_label = $EntryLayout/NameLabel

func _ready() -> void:
	icon_button.pressed.connect(_on_pressed)
	set_locked()

func _on_pressed() -> void:
	selected.emit(npc_id)

func set_locked() -> void:
	name_label.text = locked_display_text

func set_unlocked_name(display_name: String) -> void:
	name_label.text = display_name

func set_icon(texture: Texture2D) -> void:
	icon_button.texture_normal = texture
