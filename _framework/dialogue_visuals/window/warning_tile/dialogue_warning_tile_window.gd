@tool
@icon("uid://bbxaj8rh6jfm6")
extends DialogueWindow
class_name DialogueWarningTileWindow
## A simple window that houses a [WarningTile2D].
##
## Doesn't really do much.  It's just visual flair.
## [br][br]
## Can be spawned with [WindowManager].
## [br][br]
## Comes with the optional SFX events from [DialogueWindow].

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

func _process(_delta: float) -> void:
	super(_delta)
	if Engine.is_editor_hint():
		return

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Makes the housed [member tile] start shaking.
func enableTileShake() -> void:
	tile.shakingEnabled = true

## Makes the housed [member tile] stop shaking.
func disableTileShake() -> void:
	tile.shakingEnabled = false

## Updates the housed [member tile]'s shake interval.
func setShakeInterval(newInterval:float) -> void:
	tile.shakeInterval = newInterval

## Updates the housed [member tile]'s shake range.
func setShakeRange(newRange:Vector2) -> void:
	tile.shakeRange = newRange
