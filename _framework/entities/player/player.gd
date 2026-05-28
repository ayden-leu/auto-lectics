@tool
extends CharacterBody3D
class_name Player
## The main node that gets controlled by the player.
##
## The player can move around, interact with interactables, and use a grappling hook.
## [br][br]
## Comes with the following SFX events:[br]
## - death:   plays when the player dies.[br]
## - jump:    plays when the player jumps.[br]
## - respawn: plays when the player respawns.[br]

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
## Emitted when starting to respawn.
signal respawning_start()
## Emitted when finishing respawning.
signal respawning_finished()

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

@export_group("Grappling Hook")
## If this grappling hook can be used or not.
@export var grapplingHookEnabled:bool = true
## The amount of force applied when the grappling hook successfully hits.
@export var grappleAttachImpulseStrength:float = 10.0

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The anchor for the player camera to attach itself to.
@onready var cameraAnchor:Marker3D = %CameraAnchor
## [b]Internal-use only.[/b]  The raycast that lets you interact with things in the world.
@onready var _interactionRaycast:RayCast3D = %InteractionRaycast
## [b]Internal-use only.[/b]  The fade overlay.
@onready var _overlay = %FadeToBlackOverlay
## [b]Internal-use only.[/b]  Handles SFX events.
@onready var _sfxEventHandler:SfxEventHandler = %SfxEventHandler
## The grappling hook the player can use.
@onready var grapplingHook:GrapplingHook = %GrapplingHook

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
## Track if player's is stuck in place.
static var frozen:bool = false
## If the player's inputs are disabled.
static var inputEnabled:bool = true

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
## If the player is currently respawning or not.
var _respawning:bool = false
## [b]Internal-use only.[/b]
## A list of nodes freezing this.  Only has unique entries.
## The values of each key are always [code]null[/code].
static var _nodesFreezingMe:Dictionary[Node, Node] = {}
## [b]Internal-use only.[/b]
## A list of nodes disabling player input from affecting this.  Only has unique entries.
## The values of each key are always [code]null[/code].
static var _nodesDisablingInput:Dictionary[Node, Node] = {}

# ------------------------------------------------
## Grapple hook variables
# ------------------------------------------------
## True if the player is currently in the grappling state.
var isGrappling: bool = false
## If the player is allowed to grapple currently.
var canGrapple: bool = true
## The current input direction from [InputHandler] in local space,
## converted to global space.
var inputDirectionRelative: Vector2
## Track whether to send a new signal or not for whether the target looked at is grappleable
var _lookingAtGrapplable: bool = false:
	set(newState):
		if newState == _lookingAtGrapplable:
			return

		if not _lookingAtGrapplable and newState:
			looking_at_grappleable.emit()
		elif _lookingAtGrapplable and not newState:
			no_longer_looking_at_grappleable.emit()
		_lookingAtGrapplable = newState

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_recomputeJumpParameters()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
		return

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if frozen:
		velocity = Vector3.ZERO
		return
	_applyVerticalPhysics(delta)
	if isGrappling:
		var expanded:Vector3 = Vector3(inputDirectionRelative.x, 0, inputDirectionRelative.y)
		velocity = grapplingHook.applyGrapplePhysics(delta, velocity, expanded)
	move_and_slide()

	if _interactionRaycast.get_collider() != null:
		var hit = _interactionRaycast.get_collider().owner
		if _determineIfValidInteractable(hit):
			interactableThing = hit
	else:
		interactableThing = _loadBearingDummy

	if grapplingHook.enabled:
		_lookingAtGrapplable = grapplingHook.raycastCollidingWithValidTarget()


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
	grapplingHook.reset()
	respawning_finished.emit()

## Puts player at [member _lastValidPosition], but only after the fade in.
func respawn() -> void:
	if _respawning:
		return

	_respawning = true
	_sfxEventHandler.play("death")
	_overlay.startFadeIn()
	respawning_start.emit()
	await _overlay.fade_in_complete

	grapplingHook.reset()

	await get_tree().create_timer(respawnDelay).timeout

	_respawning = false
	respawnForce()
	_overlay.startFadeOut()
	_sfxEventHandler.play("respawn")

## Moves the player to [memmber respawnCheckpointLocation] immediately.
func respawnCheckpoint() -> void:
	global_position = respawnCheckpointLocation.global_position

## Fancy respawn method due to dying to [RestartLoopManagerArea3D].
func respawnFancy() -> void:
	if _respawning:
		return

	_respawning = true
	_sfxEventHandler.play("deathFancy")
	_overlay.startFadeIn()
	respawning_start.emit()
	await _overlay.fade_in_complete

	grapplingHook.reset()

	await get_tree().create_timer(respawnDelay).timeout

	_respawning = false
	respawnForce()
	_overlay.startFadeOut()
	_sfxEventHandler.play("respawnFancy")

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

## Prevents player input from affecting this.
## Also adds the disabler to [member _nodesDisablingInput].
static func disableInput(disabler:Node) -> void:
	if not inputEnabled:
		print("Player:  Input already disabled.")
		return

	if disabler in _nodesDisablingInput:
		print("Player:  Disabler [", disabler.name, "] already disabled input from player.")
		return

	print("Player:  Incrementing input disabler counter.")
	_nodesDisablingInput[disabler] = null
	print("Player:  Disabling inputs from player due to [", disabler.name, "].")
	inputEnabled = false

## Allows player input to affect this.
## Also removes the enabler from [member _nodesDisablingInput].
static func enableInput(enabler:Node) -> void:
	if inputEnabled:
		print("Player:  Input already enabled.")
		return

	if not enabler in _nodesDisablingInput:
		printerr("Player:  Enabler [", enabler.name, "] didn't disable input from player.")
		return

	print("Player:  Decrementing input disabler counter.")
	_nodesDisablingInput.erase(enabler)
	if _nodesDisablingInput.is_empty():
		print("Player:  Enabling inputs from player due to [", enabler.name, "].")
		inputEnabled = true

## Forcibly allows player input to affect this.
## Also clears [member _nodesDisablingInput].
static func enableInputForce() -> void:
	if inputEnabled:
		print("Player:  Input already enabled; don't have to force it.")
		return

	print("Player:  Forcing inputs from player to be enabled.")
	inputEnabled = true
	_nodesDisablingInput.clear()

## Freezes this player character in place.
## Also adds the freezer to [member _nodesFreezingMe].
static func freeze(freezer:Node) -> void:
	if frozen:
		print("Player:  Player already frozen.")
		return

	if freezer in _nodesFreezingMe:
		print("Player:  Freezer [", freezer.name, "] already froze the player.")
		return

	print("Player:  Incrementing nodes freezing counter.")
	_nodesFreezingMe[freezer] = null
	print("Player:  Freezing the Player due to [", freezer.name, "].")
	frozen = true

## Unfreezes this player character so they can move around again.
## Also removes the unfreezer from [member _nodesFreezingMe].
static func unfreeze(unfreezer:Node) -> void:
	if not frozen:
		print("Player:  Player already unfrozen.")
		return

	if not unfreezer in _nodesFreezingMe:
		printerr("Player:  Unfreezer [", unfreezer.name, "] didn't freeze the Player.")
		return

	print("Player:  Decrementing nodes freezing counter.")
	_nodesFreezingMe.erase(unfreezer)
	if _nodesFreezingMe.is_empty():
		print("Player:  Unfreezing Player due to [", unfreezer.name, "].")
		frozen = false

## Forcibly unfreezes this player character so they can move around again.
## Also clears [member _nodesFreezingMe].
static func unfreezeForce() -> void:
	if not frozen:
		print("Player:  Player already unfrozen; don't need to force it.")
		return
	print("Player:  Forcibly unfreezing Player.")
	frozen = false
	_nodesFreezingMe.clear()

## [b]Internal-use only.[/b]  Determines if a passed in node is a valid interactable.
func _determineIfValidInteractable(interactable:Node3D) -> bool:
	if interactable.has_method("_on_interaction"):
		return true

	return false

## Apply an impulse of speed to the player.
func _applyImpulseTowardPoint(point:Vector3, strength:float) -> void:
	var dir := (point - global_position).normalized()
	velocity += dir * strength

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Rotates the player when the mouse moves horizontally.
func _on_mouse_moved(distanceMoved:Vector2) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if not inputEnabled:
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
	if not inputEnabled:
		return

	#print(name + ": interact pressed")
	if interactableThing and interactableThing != _loadBearingDummy:
		interactableThing._on_interaction(self)

## [b]Internal-use only.[/b]  Handles logic for when the player tries to jump.
func _on_jump_pressed() -> void:
	if not inputEnabled:
		return

	#if isGrappling:
		#grapplingHook.startRecall()
	if is_on_floor():
		_sfxEventHandler.play("jump")
		jump()

## [b]Internal-use only.[/b] Handles logic for when palyer attempts to grapple hook
func _on_grapple_pressed() -> void:
	if not inputEnabled:
		return

	if isGrappling:
		grapplingHook.startRecall()
	if grapplingHookEnabled and canGrapple:
		grapplingHook.throwHook()

## [b]Internal-use only.[/b]  Handles logic for when the player inputs a new
## move direction.
func _on_updated_input_direction(newDirection:Vector2) -> void:
	if not inputEnabled:
		newDirection = Vector2.ZERO

	var direction := (transform.basis * Vector3(newDirection.x, 0, newDirection.y)).normalized()
	inputDirectionRelative = Vector2(direction.x, direction.z)
	_handleDirectionInput(direction)

## [b]Internal-use only.[/b]
## The location to move the player to upon forcing the respawn.
func _on_input_handler_respawn() -> void:
	if not inputEnabled:
		return
	grapplingHook.reset()
	respawnCheckpoint()

func _on_grappling_hook_hook_attached() -> void:
	isGrappling = true
	_applyImpulseTowardPoint(grapplingHook._attachPoint, grappleAttachImpulseStrength)

func _on_grappling_hook_hook_detached() -> void:
	isGrappling = false

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
