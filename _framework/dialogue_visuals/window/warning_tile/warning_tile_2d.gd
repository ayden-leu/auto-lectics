extends Panel
class_name WarningTile2D

# ------------------------------------------------
# onready variables
# ------------------------------------------------
@onready var label: Label = $Label
# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
var _origin: Vector2
var _rng := RandomNumberGenerator.new()
var _timer := Timer.new()
var _shake_interval: float = 0.08
var _shake_range: Vector2 = Vector2(4, 4)

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	label.text = "WARNING"
	_origin = position
	
	add_child(_timer)
	_timer.wait_time = _shake_interval
	_timer.timeout.connect(_on_shake_timer_timeout)
	_timer.start()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
func kill() -> void:
	queue_free()

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func set_origin(pos: Vector2) -> void:
	_origin = pos
	position = pos


func _on_shake_timer_timeout() -> void:
	_rng.randomize()
	position = _origin + Vector2(
		_rng.randf_range(-_shake_range.x, _shake_range.x),
		_rng.randf_range(-_shake_range.y, _shake_range.y)
	)
