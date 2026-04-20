extends Control

signal selected(npc_id: String)

@export var npc_id: String = "npc_test"
@export var locked_display_text: String = "???"

@onready var icon_button = $Button
@onready var name_label = $NameLabel

func _ready() -> void:
	#print("Entry ready start:", name, " id=", npc_id)
	#print("icon_button =", icon_button)
	#print("name_label =", name_label)

	icon_button.pressed.connect(_on_pressed)
	set_unknown()
	

func _on_pressed() -> void:
	selected.emit(npc_id)


func set_unknown() -> void:
	name_label.text = locked_display_text


func set_revealed_name(display_name: String) -> void:
	name_label.text = display_name


func set_confirmed_locked_name(display_name: String) -> void:
	name_label.text = "✓ " + display_name


func set_icon(texture: Texture2D) -> void:
	icon_button.texture_normal = texture
