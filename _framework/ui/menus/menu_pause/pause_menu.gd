extends CanvasLayer

@onready var panel = $Panel
@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var options_button = $Panel/VBoxContainer/OptionsButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton

# Preload sub-menus
const OptionsMenuScene = preload("res://_framework/ui/menus/menu_pause/OptionsMenu.tscn")

var options_menu_instance: Node = null


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Start hidden
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # Escape key by default
		if visible:
			_on_resume_pressed()
		else:
			open_pause_menu()


func open_pause_menu() -> void:
	get_tree().paused = true
	show()


func close_pause_menu() -> void:
	get_tree().paused = false
	hide()


func _on_resume_pressed() -> void:
	close_pause_menu()


func _on_options_pressed() -> void:
	if options_menu_instance == null:
		options_menu_instance = OptionsMenuScene.instantiate()
		add_child(options_menu_instance)
		options_menu_instance.closed.connect(_on_options_menu_closed)

	panel.hide()
	options_menu_instance.show()


func _on_options_menu_closed() -> void:
	panel.show()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
