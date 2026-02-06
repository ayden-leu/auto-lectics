@tool
extends CharacterBody3D
class_name Player

@onready var cameraAnchor:Marker3D = %CameraAnchor
@onready var interactionRaycast:RayCast3D = %InteractionRaycast

# TODO:  determine better values for min, max, and step once we figure out the real player size.
# =======================
@export_group("Movement - Ground")
## The player's maximum speed.
@export_range(0.0, 30.0, 0.1) var maxSpeed: float = 5.0
## The player's acceleration.
## The smaller the value, the more time it takes to reach max speed.
@export_range(0.0, 80.0, 0.5) var acceleration: float = 18.0
## THe player's deceleration.
## The smaller the value, the more time it takes to stop moving.
@export_range(0.0, 120.0, 0.5) var deceleration: float = 28.0
## Gives you a boost in movement speed when turning.
@export_range(0.0, 20.0, 0.1) var turnDecelerationBoost: float = 6.0 # setting for turn

@export_group("Movement - Air")
## The player's air acceleration.
## The smaller the value, the more time it takes to reach max speed.
@export_range(0.0, 60.0, 0.5) var airAcceleration: float = 10.0
## The player's air deceleration.
## The smaller the value, the more time it takes to stop moving.
@export_range(0.0, 60.0, 0.5) var airDeceleration: float = 6.0
## The smaller the value, the more time it takes to accelerate and decelerate.
@export_range(0.0, 1.0, 0.01) var airControl: float = 0.45

@export_group("Jump")
## The player's jump height.
@export_range(0.1, 10.0, 0.05) var jumpHeight: float = 1.2
## The amount of time it takes to reach the peak of the jump.
@export_range(0.05, 2.0, 0.01) var timeToApex: float = 0.4
## The amount of time the player stays at the peak of the jump.
@export_range(0.0, 0.35, 0.01) var apexHangTime: float = 0.04
## The higher the value, the faster the player falls.
@export_range(1.0, 4.0, 0.05) var fallGravityMultiplier: float = 2.0


var _jumpVelocity: float = 0.0
var _gravityUp: float = 0.0
var _gravityDown: float = 0.0

var _wasOnFloor: bool = false
var _timeSinceApex: float = 0.0
var _apexHangActive: bool = false


func _ready() -> void:
	_recompute_jump_params()

func _process(_delta: float) -> void:
	# Dev-ing stuff
	if Engine.is_editor_hint():
		update_configuration_warnings()
		
func _notification(_what: int) -> void:
	#unfinished wait for connect to a notficiation function that able to change data after it had been edited in  editor
	#if what == NOTIFICATION_EDITOR_PROPERTY_CHANGED:
		_recompute_jump_params()


func _recompute_jump_params() -> void:
	# avioding 0 set make system bug

	# finding g from the given h and t for reaching max hight
	_gravityUp = (2.0 * jumpHeight) / (timeToApex * timeToApex)
	_jumpVelocity = _gravityUp * timeToApex

	# able to fall down faster
	_gravityDown = _gravityUp * fallGravityMultiplier
	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	_apply_vertical_physics(delta)
	move_and_slide()


func _apply_vertical_physics(delta: float) -> void:
	if not is_on_floor():
		#if jumping, enable the hang
		if velocity.y > 0.0:
			_timeSinceApex = 0.0
			_apexHangActive = false
			# when reaching max hight, slower bit fall down speed to make jump more smoth.
		elif velocity.y <= 0.0 and not _apexHangActive and apexHangTime > 0.0:
			_apexHangActive = true
			_timeSinceApex = 0.0

		if _apexHangActive:
			_timeSinceApex += delta
			if _timeSinceApex < apexHangTime:
				velocity.y -= _gravityUp * 0.15 * delta
				return
			else:
				_apexHangActive = false

		if velocity.y > 0.0:
			velocity.y -= _gravityUp * delta
		else:
			velocity.y -= _gravityDown * delta
	else:
		_apexHangActive = false
		_timeSinceApex = 0.0

	_wasOnFloor = is_on_floor()

func jump() -> void:
	# jump enable need to set
	_recompute_jump_params()
	velocity.y = _jumpVelocity
	_apexHangActive = false
	_timeSinceApex = 0.0

func handleDirectionInput(direction: Vector3) -> void:
	var target := Vector3.ZERO
	if direction != Vector3.ZERO:
		target = direction.normalized() * maxSpeed
	
	var current_h := Vector3(velocity.x, 0.0, velocity.z)
	var desired_h := Vector3(target.x, 0.0, target.z)

	var turning := current_h.length() > 0.05 and desired_h.length() > 0.05 and current_h.normalized().dot(desired_h.normalized()) < 0.2

	var accel := acceleration
	var decel := deceleration

	if not is_on_floor():
		accel = airAcceleration
		decel = airDeceleration
		
	var physicsDelta:float = get_physics_process_delta_time()

	if desired_h.length() > 0.0:
		var step:float = accel * (1.0 if is_on_floor() else airControl) * physicsDelta
		if turning and is_on_floor():
			var turn_step:float = (decel + turnDecelerationBoost) * physicsDelta
			current_h = current_h.move_toward(Vector3.ZERO, turn_step)
		current_h = current_h.move_toward(desired_h, step)
	else:
		var step:float = decel * physicsDelta
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
		print(interactionRaycast.get_collider().owner.name)
		interactionRaycast.get_collider().owner._on_interaction()


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
