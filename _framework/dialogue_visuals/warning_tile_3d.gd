@tool
extends Node3D
class_name WarningTile3D
## @deprecated
## The warning pop-ups that appear around a [DialogueBox] during a hectic dialogue interaction.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the warning tile detects it is blocking something important.
signal blocking_visual(tile:WarningTile3D)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## The mathematical relationship between the warning tile's radius and the label's pixel size.
const _RADIUS_TO_LABEL_RATIO:float = 0.005/0.6
## How often the warning tile visually shakes.
const _SHAKE_UPDATE_INTERVAL:float = 0.1
## How far the warning tile can shake from its origin.
const _OFFSET_RANGE:Dictionary = {
	"x": 0.03,
	"y": 0.03
}

# ---------------------------------`---------------
# export variables
# ------------------------------------------------
## The radius of the warning tile from its center.
@export var radius:float = 0.6
## If the warning tile should be shaking or not.
@export var shakingEnabled:bool = true

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The text label of the warning tile. Usually says "WARNING"
@onready var _label:Label3D = %TextLabel
## [b]Internal-use only.[/b]  The warning tile's background.
@onready var _background:MeshInstance3D = %Background
## [b]Internal-use only.[/b]  The timer responsible for shaking the warning tile.
@onready var _shakeTimer:Timer = %ShakeTimer
## [b]Internal-use only.[/b]  The area that detects if the warning tile is blocking something important.
@onready var _visualArea:CollisionShape3D = %VisualArea/CollisionShape3D

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The number of times the warning tile has been moved due to blocking something important.
var numTimesRepositioned:int = 0

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## A random number generator.
var _rng:RandomNumberGenerator = RandomNumberGenerator.new()

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_updateSize()
	_shakeTimer.wait_time = _SHAKE_UPDATE_INTERVAL
	_shakeTimer.start()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_updateSize()
		return

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Kills the warning tile.
func kill() -> void:
	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## Updates the size of the warning tile.
func _updateSize() -> void:
	_background.mesh.radius = radius
	_label.pixel_size = radius * _RADIUS_TO_LABEL_RATIO
	_visualArea.shape.size.x = (radius + _OFFSET_RANGE.x) * 2
	_visualArea.shape.size.y = (radius + _OFFSET_RANGE.y) * 2

## Shakes the warning tile.
func _shake() -> void:
	_rng.randomize()
	var offsetX = _rng.randf_range(-_OFFSET_RANGE.x, _OFFSET_RANGE.x)
	var offsetY = _rng.randf_range(-_OFFSET_RANGE.y, _OFFSET_RANGE.y)
	
	_background.position.x = offsetX * radius/0.6
	_background.position.y = offsetY * radius/0.6

## Resets the position of the background to its local center.
func _resetPosition() -> void:
	_background.position.x = 0
	_background.position.y = 0

## Makes the warning tile look at the player's camera.
func lookAtCamera():
	if Engine.is_editor_hint():
		return
	look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when the shake timer times out.
func _on_shake_timer_timeout() -> void:
	if shakingEnabled:
		_shake()
	else:
		_resetPosition()
	lookAtCamera()

## [b]Internal-use only.[/b]  Handles logic for when the warning tile blocks something important.
func _on_visual_area_area_entered(_area: Area3D) -> void:
	blocking_visual.emit(self)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
