@tool
extends Node3D
class_name NPC

@export var patrol_path: Path3D
@export var patrol_enabled: bool = true
@export var patrol_speed: float = 2.0
@export var loop_path: bool = true
@export var ping_pong: bool = false
@export var wait_at_ends: float = 0.0
@export var face_move_direction: bool = true

var _follower: PathFollow3D
var _dir: float = 1.0
var _waiting: bool = false
var _last_position: Vector3

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_setup_path_follow()
	_last_position = global_position

func _setup_path_follow() -> void:
	if patrol_path == null:
		return
	
	## Create PathFollow3D child node
	_follower = PathFollow3D.new()
	_follower.name = "PathFollow"
	_follower.loop = loop_path and not ping_pong
	patrol_path.add_child(_follower)
	
	# Start at closest point
	if patrol_path.curve:
		var offset := patrol_path.curve.get_closest_offset(patrol_path.to_local(global_position))
		_follower.progress = offset
	else:
		_follower.progress = 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not patrol_enabled or patrol_path == null or _follower == null:
		return
	if _waiting:
		return
	
	var curve_len := patrol_path.curve.get_baked_length()
	_follower.progress += patrol_speed * delta * _dir
	
	# Behavior when ping pong (going back and forth on path)
	if ping_pong:
		if _follower.progress >= curve_len:
			_follower.progress = curve_len
			_dir = -1.0
			_maybe_wait()
		elif _follower.progress <= 0.0:
			_follower.progress = 0.0
			_dir = 1.0
			_maybe_wait()
	
	# Behavior when on a closed curve w/ looping enabled
	elif loop_path:
		_follower.progress = fposmod(_follower.progress, curve_len)
	# Undefined behavior - follows path once to completion
	else:
		_follower.progress = clamp(_follower.progress, 0.0, curve_len)
	
	# Move NPC directly
	#print("move")
	var target := _follower.global_position
	global_position = target
	
	# Face forward on path
	if face_move_direction:
		var move_dir := target - _last_position
		move_dir.y = 0.0
		if move_dir.length() > 0.01:
			look_at(global_position + move_dir, Vector3.UP)
	_last_position = target

## Wait at end of path before going back, if wait time is declared
func _maybe_wait() -> void:
	if wait_at_ends <= 0.0:
		return
	_waiting = true
	await get_tree().create_timer(wait_at_ends).timeout
	_waiting = false
