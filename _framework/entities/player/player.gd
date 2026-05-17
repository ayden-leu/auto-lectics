@tool
extends CharacterBody3D
class_name Player
## The main node that gets controlled by the player.
##
## The player can move around, interact with interactables, and use a grappling hook.
## [br][br]
## Comes with the following SFX events:[br]
## - death:    plays when the player dies.[br]
## - grappleExtending:  plays when the grappling hook is extending.[br]
## - grappleHitFail        plays when the grappling hook hits an unhookable target.[br]
## - grappleHitSuccess:    plays when the grappling hook hits a hookable target.[br]
## - grappleMaxRangeReached:  plays when the grappling hook reaches its max throw range.[br]
## - grappleRecall:        plays when the grappling hook is being recalled.[br]
## - grappleRecallFinish:  plays when the grappling hook is finished recalling.[br]
## - grappleRecallStart:   plays when the grappling hook is beginning to be recalled.[br]
## - grappleThrow:      plays when the player throws the grappling hook.[br]
## - jump:  plays when the player jumps.[br]
## - respawn:  plays when the player respawns.[br]

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when looking at an interactable thing.
signal looking_at_interactable()
## Emitted when no longer looking at an interactable thing.
signal no_longer_looking_at_interactable()
## Emitted when looking at a grappleable thing.
signal looking_at_grappleable()
## Emitted when no longer looking at a grappleable thing.
signal no_longer_looking_at_grappleable()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

const GRAPPLE_END_POINT = preload("uid://bqy7naymjdg4")

# ------------------------------------------------
# export variables
# ------------------------------------------------
## How long to wait before actually respawning.
@export var respawnDelay:float = 2.0
## The location to move the player to when [method respawnCheckpoint] runs.
@export var respawnCheckpointLocation: Marker3D

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
## If the player can grapple or not.
@export var grappleEnabled: bool = true
## The max range the grappling hook can be sent.
@export var grappleMaxRange: float = 20.0
## The amount of force applied when the grappling hook successfully hits.
@export var grappleAttachImpulseStrength: float = 10.0
## How much an input direction affects the player's velocity while swinging.
@export var grappleSwingInfluenceMultiplier: float = 6.0
## How fast the grappling hook moves when shot.
@export var grappleShootSpeed: float = 60.0
## How fast the grappling hook moves when recalled.
@export var grappleRecallSpeed: float = 100
## The maximum speed the player can build up while swinging.
@export var grappleMaxSpeed: float = 20.0


# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The anchor for the player camera to attach itself to.
@onready var cameraAnchor:Marker3D = %CameraAnchor
## [b]Internal-use only.[/b]  The raycast that lets you interact with things in the world.
@onready var _interactionRaycast:RayCast3D = %InteractionRaycast
## [b]Internal-use only.[/b]  The fade overlay.
@onready var _overlay = %FadeToBlackOverlay
## Handles SFX events.
@onready var _sfxEventHandler:SfxEventHandler = %SfxEventHandler


## [b]Internal-use only.[/b] The visual for the line to the grapple point
@onready var _grappleLine: MeshInstance3D = $GrappleVisuals/GrappleLine
## [b]Internal-use only.[/b] The visual for the hook at the grapple point
@onready var _grappleHook: MeshInstance3D = $GrappleVisuals/GrappleHook
## [b]Internal-use only.[/b] Marker for where the grapple hook should be released from
@onready var _grappleStartPosition: Marker3D = $CameraAnchor/GrappleStartMarker

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
			canGrapple = true
		else:
			looking_at_interactable.emit()
			canGrapple = false

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
## Track if player's is stuck in place.
static var _frozen:bool = false
## If the player's inputs are disabled.
static var _inputDisabled: bool = false
## If the player is currently respawning or not.
var _respawning:bool = false

# ------------------------------------------------
## Grapple hook variables
# ------------------------------------------------
## True if the player is currently in the grappling state.
var isGrappling: bool = false
## The point in space where the grappling hook successfully hit.
var grappleAttachPoint: Vector3
## The distance between [member _grappleStartPosition] and [member grappleAttachPoint].
var grappleCurrentLength: float = 0.0
## If the player is allowed to grapple currently.
var canGrapple: bool = true
## The current input direction from [InputHandler].
var currentInputDirection: Vector2
## If the grappling hook is currently traveling.
var grappleTraveling: bool = false
## If the grappling hook is currently being recalled.
var grappleRecalling: bool = false
## Track the target for the hook to fly to, even if no valid grapple point exists
var grappleTarget:Marker3D
## Track whether the hook's target is valid
var grappleAttachPointValid: bool = false
## Track whether to send a new signal or not for whether the target looked at is grappleable
var _lookingAtGrapplable: bool = false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_grappleLine.visible = false
	_grappleHook.visible = false
	_recomputeJumpParameters()

	var endPoint:Marker3D = GRAPPLE_END_POINT.instantiate()
	get_parent().add_child.call_deferred(endPoint)
	grappleTarget = endPoint

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
	# Update grapple hook visuals
	if grappleTraveling:
		# update grapple visuals while hook is moving
		_updateGrappleHookVisual(_delta)
	if isGrappling:
		# update grapple visuals while hook is fixed
		_updateGrappleVisuals()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _frozen:
		velocity = Vector3.ZERO
		return
	_applyVerticalPhysics(delta)
	if isGrappling:
		_applyGrapplePhysics(delta, currentInputDirection)
	move_and_slide()

	#print(_interactionRaycast.get_collider())
	if _interactionRaycast.get_collider() != null:
		var hit = _interactionRaycast.get_collider().owner
		if _determineIfValidInteractable(hit):
			interactableThing = hit
	else:
		interactableThing = _loadBearingDummy

	if grappleEnabled:
		if _determineLookingAtGrapplable() && !isGrappling:
			if !_lookingAtGrapplable:
				_lookingAtGrapplable = true
				looking_at_grappleable.emit()
		else:
			if _lookingAtGrapplable:
				_lookingAtGrapplable = false
				no_longer_looking_at_grappleable.emit()


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
	recallGrapple()
	_hideGrapple()

## Puts player at [member _lastValidPosition], but only after the fade in.
func respawn() -> void:
	if _respawning:
		return

	_respawning = true
	_sfxEventHandler.play("death")
	_overlay.startFadeIn()
	await _overlay.fade_in_complete

	recallGrapple()
	_hideGrapple()

	await get_tree().create_timer(respawnDelay).timeout

	_respawning = false
	respawnForce()
	_overlay.startFadeOut()
	_sfxEventHandler.play("respawn")

## Moves the player to [memmber respawnCheckpointLocation] immediately.
func respawnCheckpoint() -> void:
	global_position = respawnCheckpointLocation.global_position

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
	if isGrappling && !is_on_floor():
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
static func disableInput(value: bool) -> void:
	_inputDisabled = value

static func freeze(value:bool) -> void:
	_frozen = value

## [b]Internal-use only.[/b]  Determines if a passed in node is a valid interactable.
func _determineIfValidInteractable(interactable:Node3D) -> bool:
	if interactable.has_method("_on_interaction"):
		return true

	return false

# ------------------------------------------------
# Grapple hook functions
# ------------------------------------------------

## When grappling hook is thrown
func _throwGrappleHook() -> void:
	if not grappleEnabled or _inputDisabled or !canGrapple or grappleTraveling:
		return

	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	# Use camera direction for checks
	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * grappleMaxRange

	# Check if valid point is hit
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	grappleAttachPointValid = false

	# No target to hit
	if result.is_empty():
		grappleTarget.global_position = to
		grappleTarget.isInAir = true
	# Target is in range of grapple hook
	else:
		grappleTarget.global_position = result.position
		grappleTarget.isInAir = false
		# Check is target is marked as ungrappleable
		var collider: Node = result.get("collider")
		if _isValidGrappleTarget(collider):
			grappleAttachPointValid = true

	# Set variables to start sending hook out
	_grappleHook.global_position = from
	grappleTraveling = true
	grappleRecalling = false
	_grappleHook.visible = true
	_grappleLine.visible = true

	_sfxEventHandler.play("grappleThrow")


## Checks if target object is ungrappleable
func _isValidGrappleTarget(node: Node) -> bool:
	while node != null:
		if node.is_in_group("Ungrappleable"):
			return false
		node = node.get_parent()
	return true

## Checks if there is a grappleable target in range (for crosshair updating only)
func _determineLookingAtGrapplable() -> bool:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return false
	# Use camera direction for checks
	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * grappleMaxRange

	# Check if valid point is hit
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)

	# Target found
	if !result.is_empty():
		# Check to make sure target isn't marked as ungrappleable
		var collider: Node = result.get("collider")
		if _isValidGrappleTarget(collider):
			return true
	# No target or ungrappleable target
	return false

## Update the position of the grappling hook.
func _updateGrappleHookVisual(delta: float) -> void:
	var start := _grappleStartPosition.global_position

	# Case: hook is moving to target
	if !grappleRecalling:
		_grappleHook.global_position = _grappleHook.global_position.move_toward(grappleTarget.global_position, grappleShootSpeed * delta)

		if not _sfxEventHandler.getPlayerForEvent("grappleExtending").playing:
			_sfxEventHandler.play("grappleExtending")

		# When grapple reaches target
		if _grappleHook.global_position.distance_to(grappleTarget.global_position) <= 0.05:
			if grappleAttachPointValid:
				_sfxEventHandler.play("grappleHitSuccess")
				_attachGrappleHook(grappleTarget.global_position)
			else:
				if grappleTarget.isInAir:
					_sfxEventHandler.play("grappleMaxRangeReached")
				else:
					_sfxEventHandler.play("grappleHitFail")
				grappleRecalling = true

	# Case: hook is moving back to player
	else:
		_grappleHook.global_position = _grappleHook.global_position.move_toward(start, grappleRecallSpeed * delta)

		if not _sfxEventHandler.getPlayerForEvent("grappleRecall").playing:
			_sfxEventHandler.play("grappleRecall")

		# hook reaches player
		if _grappleHook.global_position.distance_to(start) <= 0.05:
			_hideGrapple()
			_sfxEventHandler.play("grappleRecallFinish")

	_updateGrappleRopeVisual(start, _grappleHook.global_position)

## Makes the grappling rope stretch between two points.
func _updateGrappleRopeVisual(start: Vector3, end: Vector3) -> void:
	var dir := end - start
	var length := dir.length()
	if length <= 0.01:
		return
	var mid := start + dir * 0.5

	_grappleLine.visible = true
	_grappleLine.global_position = mid

	var cur_basis := Basis()
	cur_basis.y = dir.normalized()
	var side := cur_basis.y.cross(Vector3.FORWARD)
	if side.length() < 0.01:
		side = basis.y.cross(Vector3.RIGHT)
	cur_basis.x = side.normalized()
	cur_basis.z = cur_basis.x.cross(cur_basis.y).normalized()
	_grappleLine.global_transform.basis = cur_basis
	_grappleLine.scale = Vector3(1.0, length, 1.0)

## Attach the grappling hook to a position.
func _attachGrappleHook(point: Vector3) -> void:
	grappleAttachPoint = point
	grappleCurrentLength = _grappleStartPosition.global_position.distance_to(grappleAttachPoint)
	_grappleHook.global_position = grappleAttachPoint
	grappleTraveling = false
	isGrappling = true

	_applyImpulseTowardPoint(grappleAttachPoint, grappleAttachImpulseStrength)

## Apply an impulse of speed to the player.
func _applyImpulseTowardPoint(point:Vector3, strength:float) -> void:
	var dir := (point - global_position).normalized()
	velocity += dir * strength

## Grapple physics, called from physics process if isGrappling
func _applyGrapplePhysics(delta: float, input_dir: Vector2) -> void:
	var to_hook := grappleAttachPoint - global_position
	var distanceToHook := to_hook.length()
	if distanceToHook <= 0.01:
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
			velocity += swing_dir * grappleSwingInfluenceMultiplier * delta

	# If rope is stretched, constrain player to rope length
	if distanceToHook > grappleCurrentLength:
		var away_velocity := velocity.dot(-rope_dir)
		# remove velocity moving farther away from hook
		if away_velocity > 0.0:
			velocity -= (-rope_dir) * away_velocity
		# correct position back onto rope sphere
		global_position = grappleAttachPoint - rope_dir * grappleCurrentLength

	# Set velocity to max it if exceeds it
	_limitGrappleSpeed()

## Lower player speed if it exceeds threshold while grappling
func _limitGrappleSpeed() -> void:
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if horizontal.length() > grappleMaxSpeed:
		horizontal = horizontal.normalized() * grappleMaxSpeed
		velocity.x = horizontal.x
		velocity.z = horizontal.z

## Update grappling hook visuals for the line while hooked
func _updateGrappleVisuals() -> void:
	var start := _grappleStartPosition.global_position
	var end := grappleAttachPoint

	_grappleHook.global_position = end
	_grappleHook.visible = true
	_updateGrappleRopeVisual(start, end)

## De-attach grapple hook from surface
func recallGrapple() -> void:
	isGrappling = false
	grappleAttachPointValid = false
	grappleTraveling = true
	grappleRecalling = true

	_sfxEventHandler.play("grappleRecallStart")

## End grapple hook sequence when it returns to player
func _hideGrapple() -> void:
	grappleTraveling = false
	grappleRecalling = false
	_grappleHook.visible = false
	_grappleLine.visible = false

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Rotates the player when the mouse moves horizontally.
func _on_mouse_moved(distanceMoved:Vector2) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if _inputDisabled:
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
	if _inputDisabled:
		return

	#print(name + ": interact pressed")
	if interactableThing and interactableThing != _loadBearingDummy:
		interactableThing._on_interaction(self)

## [b]Internal-use only.[/b]  Handles logic for when the player tries to jump.
func _on_jump_pressed() -> void:
	if _inputDisabled:
		return

	#if isGrappling:
		#recallGrapple()
	if is_on_floor():
		_sfxEventHandler.play("jump")
		jump()

## [b]Internal-use only.[/b] Handles logic for when palyer attempts to grapple hook
func _on_grapple_pressed() -> void:
	if _inputDisabled:
		return

	if isGrappling:
		recallGrapple()
	else:
		_throwGrappleHook()

## [b]Internal-use only.[/b]  Handles logic for when the player inputs a new
## move direction.
func _on_updated_input_direction(newDirection:Vector2) -> void:
	if _inputDisabled:
		currentInputDirection = Vector2.ZERO
	else:
		currentInputDirection = newDirection

	var direction := (transform.basis * Vector3(newDirection.x, 0, newDirection.y)).normalized()
	_handleDirectionInput(direction)

## [b]Internal-use only.[/b]
## The location to move the player to upon forcing the respawn.
func _on_input_handler_respawn() -> void:
	if _inputDisabled:
		return
	recallGrapple()
	_hideGrapple()
	respawnCheckpoint()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if self != get_tree().edited_scene_root:
		if not respawnCheckpointLocation:
			warnings.push_back(
				"The respawn checkpoint location of this player is not set."
			)

	return warnings
