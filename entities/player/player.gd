@tool
extends CharacterBody3D
class_name Player



@onready var cameraAnchor:Marker3D = %CameraAnchor
@onready var interactionRaycast:RayCast3D = %InteractionRaycast

# -----------------------------
# Movement Tuning (Heavy Feel)
# -----------------------------
@export_group("Movement - Ground")
@export_range(0.0, 30.0, 0.1) var max_speed: float = 5.0
@export_range(0.0, 80.0, 0.5) var acceleration: float = 18.0   # smaller means more time to acc
@export_range(0.0, 120.0, 0.5) var deceleration: float = 28.0   # smaller _ more hard to stop
@export_range(0.0, 20.0, 0.1) var turn_deceleration_boost: float = 6.0 # setting for turn

@export_group("Movement - Air")
@export_range(0.0, 60.0, 0.5) var air_acceleration: float = 10.0
@export_range(0.0, 60.0, 0.5) var air_deceleration: float = 6.0
@export_range(0.0, 1.0, 0.01) var air_control: float = 0.45

# -----------------------------
# Jump Tuning
# -----------------------------
@export_group("Jump")
@export_range(0.1, 10.0, 0.05) var jump_height: float = 1.2
@export_range(0.05, 2.0, 0.01) var time_to_apex: float = 0.4
# “到达最高点的时间”越长越飘

@export_range(0.0, 0.35, 0.01) var apex_hang_time: float = 0.04


@export_range(1.0, 4.0, 0.05) var fall_gravity_multiplier: float = 2.0
@export_range(0.6, 2.0, 0.05) var low_jump_multiplier: float = 1.35


# -----------------------------
# Internals
# -----------------------------
var _jump_velocity: float = 0.0
var _gravity_up: float = 0.0
var _gravity_down: float = 0.0

var _was_on_floor: bool = false
var _time_since_apex: float = 0.0
var _apex_hang_active: bool = false


func _ready() -> void:
	_recompute_jump_params()
	

func _process(_delta: float) -> void:
	# Dev-ing stuff
	if Engine.is_editor_hint():
		update_configuration_warnings()
		
func _notification(what: int) -> void:
	#unfinished wait for connect to a notficiation function that able to change data after it had been edited in  editor
	#if what == NOTIFICATION_EDITOR_PROPERTY_CHANGED:
		_recompute_jump_params()


func _recompute_jump_params() -> void:
	#avioding 0 set make system bug

	#finding g from the given h and t for reaching max hight
	_gravity_up = (2.0 * jump_height) / (time_to_apex * time_to_apex)
	_jump_velocity = _gravity_up * time_to_apex

	# able to fall down faster
	_gravity_down = _gravity_up * fall_gravity_multiplier
	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	_apply_vertical_physics(delta)
	move_and_slide()


func _apply_vertical_physics(delta: float) -> void:
	var on_floor := is_on_floor()

	if not on_floor:
		#if jumping, enable the hang
		if velocity.y > 0.0:
			_time_since_apex = 0.0
			_apex_hang_active = false
			# when reaching max hight, slower bit fall down speed to make jump more smoth.
		elif velocity.y <= 0.0 and not _apex_hang_active and apex_hang_time > 0.0:
			_apex_hang_active = true
			_time_since_apex = 0.0

		#
		if _apex_hang_active:
			_time_since_apex += delta
			if _time_since_apex < apex_hang_time:
				velocity.y -= _gravity_up * 0.15 * delta
				return
			else:
				_apex_hang_active = false

		
		if velocity.y > 0.0:
			velocity.y -= _gravity_up * delta
		else:
			velocity.y -= _gravity_down * delta
	else:
		_apex_hang_active = false
		_time_since_apex = 0.0

	_was_on_floor = on_floor

func jump() -> void:
	# jump enable need to set
	_recompute_jump_params()
	velocity.y = _jump_velocity
	_apex_hang_active = false
	_time_since_apex = 0.0


## Modifies velocity so `move_and_slide()` can move the player
#func handleDirectionInput(direction:Vector3) -> void:
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
		
func handleDirectionInput(direction: Vector3) -> void:
	# 只处理水平速度
	var target := Vector3.ZERO
	if direction != Vector3.ZERO:
		target = direction.normalized() * max_speed

	var on_floor := is_on_floor()

	
	var current_h := Vector3(velocity.x, 0.0, velocity.z)
	var desired_h := Vector3(target.x, 0.0, target.z)

	var turning := current_h.length() > 0.05 and desired_h.length() > 0.05 and current_h.normalized().dot(desired_h.normalized()) < 0.2

	var accel := acceleration
	var decel := deceleration

	if not on_floor:
		accel = air_acceleration
		decel = air_deceleration

	# 用 move_toward 做“渐进式变化”
	if desired_h.length() > 0.0:
		var step := accel * (1.0 if on_floor else air_control) * get_physics_process_delta_time()
		if turning and on_floor:
			# 转向时先“刹一下”，避免飘移感太强
			var turn_step := (decel + turn_deceleration_boost) * get_physics_process_delta_time()
			current_h = current_h.move_toward(Vector3.ZERO, turn_step)
		current_h = current_h.move_toward(desired_h, step)
	else:
		var step := decel * get_physics_process_delta_time()
		current_h = current_h.move_toward(Vector3.ZERO, step)

	velocity.x = current_h.x
	velocity.z = current_h.z

# Rotates the player when the mouse moves horizontally
func _onMouseMoved(distanceMoved:Vector2) -> void:
	#print(name + ": mouse moved")
	rotation_degrees.y += -distanceMoved.x
	interactionRaycast.rotation_degrees.x -= -distanceMoved.y


func _onInteractPressed() -> void:
	#print(name + ": interact pressed")
	if interactionRaycast.is_colliding():
		interactionRaycast.get_collider().owner._onInteraction()


# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	var numInputHandlers:int = get_tree().get_node_count_in_group("InputHandler")
	
	if numInputHandlers < 1:
		warnings.push_back(
			"There isn't a InputHandler node, so the player won't be able to the player character.
			Consider adding an InputHandler node from the helpers folder.
		")
	elif numInputHandlers > 1:
		warnings.push_back(
			"There are too many InputHandler nodes.
			This won't crash the game, but it may lead to unexpected behavior.
		")
	
	return warnings
