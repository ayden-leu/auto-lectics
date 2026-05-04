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
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	super()
	windowType = "warning_tile"

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
