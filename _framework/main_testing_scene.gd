extends Node

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
@onready var _button_grid: GridContainer = $GridContainer
@onready var _test_scene_container: Node = $TestSceneContainer
@onready var _back_button: Button = $BackButton

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
var _current_test_scene: Node
# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
#func _ready() -> void:
	# super()  # needed if inheriting a custom class with its own _ready().  Will run the inherited class' _ready() function.
func _ready() -> void:
	_show_hub()
#func _process(delta: float) -> void:
	#super(delta)  # needed if inheriting a custom class with its own _process().  Will run the inherited class' _process() function.

#func _physics_process(delta: float) -> void:
	#super(delta)  # needed if inheriting a custom class with its own _physics_process().  Will run the inherited class' _physics_process() function.

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
func _input(event: InputEvent) -> void:
	if not is_instance_valid(_current_test_scene):
		return

	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.keycode == KEY_Q:
		_show_hub()
		get_viewport().set_input_as_handled()
		
func _load_test_scene(scene_path: String) -> void:
	if is_instance_valid(_current_test_scene):
		_current_test_scene.queue_free()

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("Could not load test scene: %s" % scene_path)
		return

	_current_test_scene = packed_scene.instantiate()
	_test_scene_container.add_child(_current_test_scene)
	_button_grid.hide()
	_back_button.show()

func _show_hub() -> void:
	if is_instance_valid(_current_test_scene):
		_current_test_scene.queue_free()
		_current_test_scene = null

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_button_grid.show()
	_back_button.hide()
	
func _on_load_test_audio_loading_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_audio_loading.tscn")


func _on_load_test_console_command_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_console_command.tscn")


func _on_load_test_death_plane_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_death_plane.tscn")


func _on_load_test_dialogue_loading_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_dialogue_loading.tscn")


func _on_load_test_label_preset_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_label_preset.tscn")


func _on_load_test_menu_manager_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_menu_manager.tscn")


func _on_load_test_npc_interaction_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_npc_interaction.tscn")


func _on_load_test_npc_patrol_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_npc_patrol.tscn")


func _on_load_test_player_movement_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_player_movement.tscn")


func _on_load_test_shader_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_shader.tscn")


func _on_load_test_story_flags_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_story_flags.tscn")


func _on_load_test_waterdrop_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_waterdrop.tscn")


func _on_load_test_window_manager_pressed() -> void:
	_load_test_scene("res://_framework/test_scenes/test_window_manager.tscn")


func _on_back_button_pressed() -> void:
	_show_hub()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
