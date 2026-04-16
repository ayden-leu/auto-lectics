extends Control

signal selected(npc_id: String)

@export var npc_id: String = "npc_test"
@export var locked_display_text: String = "???"

@onready var icon_button = $TextureButton
@onready var name_label = $NameLabel

func _ready() -> void:
	print("Entry ready start:", name, " id=", npc_id)
	print("icon_button =", icon_button)
	print("name_label =", name_label)

	if icon_button == null:
		push_error("icon_button is null in " + name)
		return
	if name_label == null:
		push_error("name_label is null in " + name)
		return

	icon_button.pressed.connect(_on_pressed)
	set_locked()

	print("Entry ready done:", name, " label=", name_label.text)

func _on_pressed() -> void:
	print("Pressed entry:", npc_id)
	selected.emit(npc_id)

func set_locked() -> void:
	name_label.text = locked_display_text

func set_unlocked_name(display_name: String) -> void:
	name_label.text = display_name

func set_icon(texture: Texture2D) -> void:
	icon_button.texture_normal = texture
