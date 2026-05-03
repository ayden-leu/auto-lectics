@tool
@icon("uid://bbxaj8rh6jfm6")
extends DialogueWindow
class_name DialogueWarningTile

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## Holds reference to the warning tile scene
@onready var warning_tile_scene: PackedScene = preload("uid://c1qmg4lyrgjqc")

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Number of tiles that should appear in hectic mode
var num_warnings: int = 6

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b] Contains the list of instantiated warning tiles
var _spawned_warnings: Array[WarningTile2D] = []

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
func spawn_warnings(main_window_rect: Rect2 = Rect2()) -> void:
	for i in range(num_warnings):
		var tile := warning_tile_scene.instantiate()
		tile.visible = false
		add_child(tile)
		
		await get_tree().process_frame
		
		var pos:Vector2 = FR_WindowManager.getRandomPositionOnScreen(tile.size, main_window_rect)
		tile.set_origin(pos)
		_spawned_warnings.push_back(tile)
		tile.visible = true
