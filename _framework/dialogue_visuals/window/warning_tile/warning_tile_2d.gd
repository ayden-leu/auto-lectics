extends Control
class_name WarningTile2D

# ------------------------------------------------
# export variables
# ------------------------------------------------
## If the shaking affect should be enabled for this tile.
@export var shakingEnabled:bool = true
## The amount of time between "shakes."
@export var shakeInterval:float = 0.08
## The max offset this tile can "shake" to, in pixels, from the origin.
## e.g  (4, 2) means 4 pixels left and right, and 2 pixels up and down.
@export var shakeRange:Vector2 = Vector2(4, 4)

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## The timer that handles when a "shake" occurs.
@onready var _shakeTimer = %ShakeTimer

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  The initial origin of this tile.
var _origin: Vector2
## [b]Internal-use only.[/b]  An RNG instance.
var _rng := RandomNumberGenerator.new()
var _shake_range: Vector2 = Vector2(4, 4)

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	_origin = position
	_shakeTimer.wait_time = shakeInterval
	_shakeTimer.start()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
func kill() -> void:
	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func updateOrigin(pos: Vector2) -> void:
	_origin = pos
	position = pos

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_shake_timer_timeout() -> void:
	if not shakingEnabled:
		return
	
	_rng.randomize()
	position = _origin + Vector2(
		_rng.randf_range(-_shake_range.x, _shake_range.x),
		_rng.randf_range(-_shake_range.y, _shake_range.y)
	)
