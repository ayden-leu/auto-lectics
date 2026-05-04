@tool
@icon("uid://bbxaj8rh6jfm6")
extends DialogueWindow
class_name DialogueWarningTileWindow

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## The warning tile for this window.
@onready var tile:WarningTile2D = %WarningTile2d

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
func enableTileShake() -> void:
	tile.shakingEnabled = true
	
func disableTileShake() -> void:
	tile.shakingEnabled = false

func setShakeInterval(newInterval:float) -> void:
	tile.shakeInterval = newInterval

func setShakeRange(newRange:Vector2) -> void:
	tile.shakeRange = newRange

#func spawn_warnings() -> void:
	#for i in range(num_warnings):
		#var tile := _warningTileScene.instantiate()
		#tile.visible = false
		#add_child(tile)
		#
		#await get_tree().process_frame
		#
		#var pos:Vector2 = FR_WindowManager.getRandomPositionOnScreen(tile.size)
		#tile.set_origin(pos)
		#_spawned_warnings.push_back(tile)
		#tile.visible = true
