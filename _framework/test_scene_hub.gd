extends Node

# NOTE:  key combo to go back to the hub is CTRL+Q

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Where the test scenes are stored.
const _STORAGE_PATH:String = "res://_framework/test_scenes/"
## [b]Internal-use only.[/b]
## What each test scene's name is prefixed with.
const _SCENE_PREFIX:String = "test_"
## [b]Internal-use only.[/b]
## The file extension of each test scene.
const _FILE_EXTENSION:String = ".tscn"

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Holds the buttons that load each test scene.
@onready var _mainPanel:Control = %MainPanel
## [b]Internal-use only.[/b]
## Holds the scene that is loaded.
@onready var _sceneHolder:Node = %SceneHolder
## [b]Internal-use only.[/b]
## The button that returns to this scene.
@onready var _backButton:Button = %BackButton

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The currently loaded scene.
var _currentTestScene:Node

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_returnToHub()

func _input(event: InputEvent) -> void:
	if not is_instance_valid(_currentTestScene):
		return

	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.keycode == KEY_Q:
		_returnToHub()
		get_viewport().set_input_as_handled()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Loads a test scene scene.
func _loadTestScene(sceneName: String) -> void:
	if is_instance_valid(_currentTestScene):
		_currentTestScene.queue_free()

	var fullPath:String = _STORAGE_PATH + _SCENE_PREFIX + sceneName + _FILE_EXTENSION
	var packed_scene := load(fullPath) as PackedScene
	if packed_scene == null:
		push_error("Could not load test scene: %s" % fullPath)
		return

	_currentTestScene = packed_scene.instantiate()
	_sceneHolder.add_child(_currentTestScene)
	_mainPanel.hide()
	_backButton.show()

## [b]Internal-use only.[/b]
## Forecibly rturns to the main hub.
func _returnToHub() -> void:
	if is_instance_valid(_currentTestScene):
		_currentTestScene.queue_free()
		_currentTestScene = null

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_mainPanel.show()
	_backButton.hide()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_load_test_audio_loading_pressed() -> void:
	_loadTestScene("audio_loading")

func _on_load_test_console_command_pressed() -> void:
	_loadTestScene("console_command")

func _on_load_test_death_plane_pressed() -> void:
	_loadTestScene("death_plane")

func _on_load_test_dialogue_loading_pressed() -> void:
	_loadTestScene("dialogue_loading")

func _on_load_test_label_preset_pressed() -> void:
	_loadTestScene("label_preset")

func _on_load_test_menu_manager_pressed() -> void:
	_loadTestScene("menu_manager")

func _on_load_test_npc_interaction_pressed() -> void:
	_loadTestScene("npc_interaction")

func _on_load_test_npc_patrol_pressed() -> void:
	_loadTestScene("npc_patrol")

func _on_load_test_player_movement_pressed() -> void:
	_loadTestScene("player_movement")

func _on_load_test_shader_pressed() -> void:
	_loadTestScene("shader")

func _on_load_test_story_flags_pressed() -> void:
	_loadTestScene("story_flags")

func _on_load_test_waterdrop_pressed() -> void:
	_loadTestScene("waterdrop")

func _on_load_test_window_manager_pressed() -> void:
	_loadTestScene("window_manager")

func _on_back_button_pressed() -> void:
	_returnToHub()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
