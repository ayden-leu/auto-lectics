extends PanelContainer

signal closed

@onready var window_mode_button = $VBoxContainer/WindowModeButton
@onready var keybinds_button = $VBoxContainer/KeybindsButton
@onready var back_button = $VBoxContainer/BackButton

const KeybindsMenuScene = preload("res://_framework/ui/menus/menu_pause/KeybindsMenu.tscn")

var keybinds_menu_instance: Node = null

# Cycles through: Windowed -> Fullscreen -> Borderless -> Windowed
var window_modes = [
	{"label": "Windowed",          "mode": DisplayServer.WINDOW_MODE_WINDOWED,    "flag": 0},
	{"label": "Fullscreen",        "mode": DisplayServer.WINDOW_MODE_FULLSCREEN,   "flag": 0},
	{"label": "Borderless Windowed","mode": DisplayServer.WINDOW_MODE_WINDOWED,    "flag": DisplayServer.WINDOW_FLAG_BORDERLESS},
]
var current_mode_index: int = 0


func _ready() -> void:
	window_mode_button.pressed.connect(_on_window_mode_pressed)
	keybinds_button.pressed.connect(_on_keybinds_pressed)
	back_button.pressed.connect(_on_back_pressed)
	_update_window_mode_label()


func _update_window_mode_label() -> void:
	window_mode_button.text = "Window Mode: " + window_modes[current_mode_index]["label"]


func _on_window_mode_pressed() -> void:
	current_mode_index = (current_mode_index + 1) % window_modes.size()
	var mode_data = window_modes[current_mode_index]

	# Clear borderless flag first, then apply new mode
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_mode(mode_data["mode"])

	if mode_data["flag"] != 0:
		DisplayServer.window_set_flag(mode_data["flag"], true)

	_update_window_mode_label()


func _on_keybinds_pressed() -> void:
	if keybinds_menu_instance == null:
		keybinds_menu_instance = KeybindsMenuScene.instantiate()
		get_parent().add_child(keybinds_menu_instance)
		keybinds_menu_instance.closed.connect(_on_keybinds_menu_closed)

	hide()
	keybinds_menu_instance.show()


func _on_keybinds_menu_closed() -> void:
	show()


func _on_back_pressed() -> void:
	hide()
	closed.emit()
