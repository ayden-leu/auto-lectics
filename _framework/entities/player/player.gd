@tool
extends CharacterBody3D
class_name Player
## The main node that gets controlled by the player.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when looking at an interactable thing.
signal looking_at_interactable()
## Emitted when no longer looking at an interactable thing.
signal no_longer_looking_at_interactable()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## How long to wait before actually respawning.
@export var respawnDelay:float = 2.0

@export_group("Movement - Ground")
## The player's maximum speed.
@export_range(0.0, 30.0, 0.1) var maxSpeed: float = 20.0
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
@export_range(0.0, 1.0, 0.01) var airControl: float = 1.0

@export_group("Jump")
## The player's jump height.
@export_range(0.1, 10.0, 0.05) var jumpHeight: float = 1.2:
	set(value):
		jumpHeight = value
		_recomputeJumpParameters()
## The amount of time it takes to reach the peak of the jump.
@export_range(0.05, 2.0, 0.01) var timeToApex: float = 0.4:
	set(value):
		timeToApex = value
		_recomputeJumpParameters()
## The amount of time the player stays at the peak of the jump.
@export_range(0.0, 0.35, 0.01) var apexHangTime: float = 0.04
## The higher the value, the faster the player falls.
@export_range(1.0, 4.0, 0.05) var fallGravityMultiplier: float = 2.0:
	set(value):
		fallGravityMultiplier = value
		_recomputeJumpParameters()

@export_group("Camera")
## A multiplier that gets applied to the distance the mouse moves.
@export var mouseSentitivity := 1
## Max angle which the camera can turn to; prevents flipping at top
@export var maxPitchDegrees := 89.0

@export_group("Grapple")
## Set whether grappling is possible or not
@export var grapple_enabled: bool = true
## Set grappling hook range
@export var grapple_max_length: float = 25.0
## Set how speed at which grapple sends you forward when attaching
@export var grapple_initial_impulse: float = 10.0
## Set how fast the swing sends you
@export var grapple_swing_input_force: float = 6.0


# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The anchor for the player camera to attach itself to.
@onready var cameraAnchor:Marker3D = %CameraAnchor
## [b]Internal-use only.[/b]  The raycast that lets you interact with things in the world.
@onready var _interactionRaycast:RayCast3D = %InteractionRaycast
## [b]Internal-use only.[/b]  The fade overlay.
@onready var _overlay = %FadeToBlackOverlay
## [b]Internal-use only.[/b]  The [AudioStreamPlayer]s that play sound events.
@onready var _sfxPlayer:Dictionary = {
	"respawn": %SFX/respawn,
	"death": %SFX/death
}
## [b]Internal-use only.[/b] The visual for the line to the grapple point
@onready var grapple_line: MeshInstance3D = $GrappleVisuals/GrappleLine
## [b]Internal-use only.[/b] The visual for the hook at the grapple point
@onready var grapple_hook_visual: MeshInstance3D = $GrappleVisuals/GrappleHookVisual
## [b]Internal-use only.[/b] Marker for where the grapple hook should be released from
@onready var grapple_start_marker: Marker3D = $CameraAnchor/GrappleStartMarker
# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The interactable thing the player is looking at during this moment.
var interactableThing:Node3D = null:
	set(thing):
		if thing == interactableThing:
			return
		interactableThing = thing
		
		if thing == _loadBearingDummy:
			no_longer_looking_at_interactable.emit()
			can_grapple = true
		else:
			looking_at_interactable.emit()
			can_grapple = false

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Purely to fix a bug where when looking at a thing
## and that thing becomes [code]null[/code] (e.g via [method queue_free()],
## the "looking_at_interactable" signals don't emit due to
## the old value of [member interactableThing] becoming [code]null[/code] on
## the same frame as the new value being [code]null[/code].
var _loadBearingDummy:Node3D = Node3D.new()
## [b]Internal-use only.[/b]  The vertical velocity applied when jumping.
## Calculated in [method _recomputeJumpParameters]
var _jumpVelocity: float = 0.0
## [b]Internal-use only.[/b]  Calculated in [method _recomputeJumpParameters]
var _gravityUp: float = 0.0
## [b]Internal-use only.[/b]  Calculated in [method _recomputeJumpParameters]
var _gravityDown: float = 0.0
## [b]Internal-use only.[/b]  The previous on floor state of the player.
var _wasOnFloor: bool = false
## [b]Internal-use only.[/b]  Keeps track of how long the player has been at the apex of their jump.
var _timeSinceApex: float = 0.0
## [b]Internal-use only.[/b]  If the player should be able to hang around at the aapex of their jump.
var _apexHangActive: bool = false
## [b]Internal-use only.[/b]  Save last location where character is grounded.
var _lastValidPosition: Vector3
## Track if player's movement is frozen
var input_frozen: bool = false
## Track whether player is in grapple state or not
var is_grappling: bool = false
## Track where the grappling hook is currently attached to
var grapple_point: Vector3
## Track how long the grappling hook currently is (length from target)
var grapple_length: float = 0.0
## Track if interactable NPC is being looked at or not, so grapple should be off
var can_grapple: bool = true
## Track current input direction
var input_direction: Vector2

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	grapple_line.visible = false
	grapple_hook_visual.visible = false
	_recomputeJumpParameters()
	
	AudioLoader.loadSfxFromId("respawn", _sfxPlayer.respawn.stream)
	AudioLoader.loadSfxFromId("death", _sfxPlayer.death.stream)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if input_frozen:
		velocity = Vector3.ZERO
		return
	_applyVerticalPhysics(delta)
	apply_grapple_physics(delta, input_direction)
	move_and_slide()
	
	#print(_interactionRaycast.get_collider())
	if _interactionRaycast.get_collider() != null:
		var hit = _interactionRaycast.get_collider().owner
		if _determineIfValidInteractable(hit):
			interactableThing = hit
	else:
		interactableThing = _loadBearingDummy
	
	# Update grappling visuals
	if is_grappling:
		_update_grapple_visuals()
	

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Makes the player jump.
func jump() -> void:
	# jump enable need to set
	_recomputeJumpParameters()
	velocity.y = _jumpVelocity
	_apexHangActive = false
	_timeSinceApex = 0.0

## Puts player at [member _lastValidPosition] immediately.
func respawnForce():
	velocity = Vector3.ZERO
	global_position = _lastValidPosition
	global_position.y += 0.1

## Puts player at [member _lastValidPosition], but only after the fade in.
func respawn() -> void:
	_sfxPlayer.death.play()
	_overlay.startFadeIn()
	await _overlay.fade_in_complete
	
	await get_tree().create_timer(respawnDelay).timeout
	
	respawnForce()
	_overlay.startFadeOut()
	_sfxPlayer.respawn.play()

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Calculates jumping parameters based on the export variable values.
func _recomputeJumpParameters() -> void:
	if Engine.is_editor_hint():
		return
	# avioding 0 set make system bug

	# finding g from the given h and t for reaching max hight
	_gravityUp = (2.0 * jumpHeight) / (timeToApex * timeToApex)
	_jumpVelocity = _gravityUp * timeToApex

	# able to fall down faster
	_gravityDown = _gravityUp * fallGravityMultiplier

## [b]Internal-use only.[/b]  Applies gravity.
func _applyVerticalPhysics(delta: float) -> void:
	if not is_on_floor():
		# if jumping, enable the hang
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
	else: # logic for when on floor
		_apexHangActive = false
		_timeSinceApex = 0.0
		_lastValidPosition = global_position

	_wasOnFloor = is_on_floor()

## [b]Internal-use only.[/b]  Handles movement input from the player.
func _handleDirectionInput(direction: Vector3) -> void:
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
	
	## Do not process air drift if grappling, so the two calcs don't overlap
	if is_grappling && !is_on_floor():
		return
		
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

## Freeze player upon interacting with NPC
func set_input_frozen(value: bool) -> void:
	input_frozen = value

## [b]Internal-use only.[/b]  Determines if a passed in node is a valid interactable.
func _determineIfValidInteractable(interactable:Node3D) -> bool:
	if interactable.has_method("_on_interaction"):
		return true
	
	return false


## When grappling hook is thrown
func throw_grapple() -> void:
	if not grapple_enabled or input_frozen or !can_grapple:
		return
	
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		print("no camera")
		return
	
	# Use camera direction for checks
	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * grapple_max_length
	
	# Check if valid point is hit
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	
	if result.is_empty():
		return
	
	# Check is target is marked as ungrappleable
	var collider: Node = result.get("collider")
	if _is_ungrappleable(collider):
		return
	
	# Set grapple true and store values of grapple point
	grapple_point = result.position
	grapple_length = global_position.distance_to(grapple_point)
	is_grappling = true
	
	# slight impulse toward hook
	var dir := (grapple_point - global_position).normalized()
	velocity += dir * grapple_initial_impulse
	
	# Set visuals
	grapple_hook_visual.global_position = grapple_point
	grapple_hook_visual.visible = true
	grapple_line.visible = true

# Checks if target object is ungrappleable
func _is_ungrappleable(node: Node) -> bool:
	while node != null:
		if node.is_in_group("Ungrappleable"):
			return true
		node = node.get_parent()
	return false

# Function to turn off grapple hook
func release_grapple() -> void:
	is_grappling = false
	# turn off visuals
	grapple_hook_visual.visible = false
	grapple_line.visible = false

# Grapple physics, called from physics process if is_grappling
func apply_grapple_physics(delta: float, input_dir: Vector2) -> void:
	if not is_grappling:
		return
	
	var to_hook := grapple_point - global_position
	var distance := to_hook.length()
	
	if distance <= 0.01:
		return
	
	var rope_dir := to_hook.normalized()
	
	# Let player input influence swing trajectory
	var camera := get_viewport().get_camera_3d()
	if camera:
		var cam_basis := camera.global_transform.basis
		var forward := -cam_basis.z
		var right := cam_basis.x
		
		forward.y = 0.0
		right.y = 0.0
		forward = forward.normalized()
		right = right.normalized()
		
		var swing_dir := (right * input_dir.x + forward * -input_dir.y).normalized()
		if swing_dir.length() > 0.01:
			velocity += swing_dir * grapple_swing_input_force * delta
	
	# If rope is stretched, constrain player to rope length
	if distance > grapple_length:
		var away_velocity := velocity.dot(-rope_dir)
		
		# remove velocity moving farther away from hook
		if away_velocity > 0.0:
			velocity -= (-rope_dir) * away_velocity
		
		# correct position back onto rope sphere
		global_position = grapple_point - rope_dir * grapple_length

## Update grappling hook visuals for the line
func _update_grapple_visuals() -> void:
	var start := grapple_start_marker.global_position
	var end := grapple_point

	var dir := end - start
	var length := dir.length()
	if length <= 0.01:
		return

	var mid := start + dir * 0.5

	grapple_hook_visual.global_position = end
	grapple_hook_visual.visible = true

	grapple_line.visible = true
	grapple_line.global_position = mid

	var cur_basis := Basis()
	cur_basis.y = dir.normalized()
	cur_basis.x = cur_basis.y.cross(Vector3.FORWARD).normalized()
	if cur_basis.x.length() < 0.01:
		cur_basis.x = cur_basis.y.cross(Vector3.RIGHT).normalized()
	cur_basis.z = cur_basis.x.cross(cur_basis.y).normalized()

	grapple_line.global_transform.basis = cur_basis
	grapple_line.scale = Vector3(1.0, length, 1.0)


# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Rotates the player when the mouse moves horizontally.
func _on_mouse_moved(distanceMoved:Vector2) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if input_frozen:
		return
	# horizontal rotation
	rotation_degrees.y += -distanceMoved.x * mouseSentitivity
	
	# pitch (on anchor)
	cameraAnchor.rotation_degrees.x += -distanceMoved.y * mouseSentitivity
	# Prevent camera from flipping at top of rotation
	cameraAnchor.rotation_degrees.x = clamp(
		cameraAnchor.rotation_degrees.x, -maxPitchDegrees, maxPitchDegrees
	)

## [b]Internal-use only.[/b]  Handles logic for when the player wants to interact
## with something.
func _on_interact_pressed() -> void:
	#print(name + ": interact pressed")
	if interactableThing and interactableThing != _loadBearingDummy:
		interactableThing._on_interaction(self)

## [b]Internal-use only.[/b]  Handles logic for when the player tries to jump.
func _on_jump_pressed() -> void:
	if is_grappling:
		release_grapple()
	if is_on_floor():
		jump()

## [b]Internal-use only.[/b] Handles logic for when palyer attempts to grapple hook
func _on_grapple_pressed() -> void:
	if is_grappling:
		release_grapple()
	else:
		throw_grapple()

## [b]Internal-use only.[/b]  Handles logic for when the player inputs a new
## move direction.
func _on_updated_input_direction(newDirection:Vector2) -> void:
	input_direction = newDirection
	var direction := (transform.basis * Vector3(newDirection.x, 0, newDirection.y)).normalized()
	_handleDirectionInput(direction)

#temporary code for Spring Playtest week 3
func _on_input_handler_respawn() -> void:
	position = Vector3(0,0,1)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
