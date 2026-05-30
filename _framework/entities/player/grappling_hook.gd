@tool
@icon("uid://d3bctx6al0yha")
extends Node
class_name GrapplingHook
## A grappling hook that can be thrown and attached to a grapplable object.
##
## To use, add an inherited scene to the node you wish to give a grappling hook to,
## and assign the appropriate export fields.
## [br][br]
## Currently, any collision shapes that are on the Environment collision layer
## are grappleable.  If you want to make such a collision shape
## ungrapplable, add it to the global "Ungrappleable" group
## (with the node selected, go to the right panel, the node tab, then the group tab).
## If that node or any of its parents are part of that group, it will be ungrapplable.
## [br][br]
## When the hook is thrown with [method throwHook], a hook will be sent straight
## to the target location and not affected by gravity.
## Once the hook reaches a valid target location, it will attach itself and
## the user will be able to swing from that point.
## The target location is determined on call, meaning if the target location is
## no longer on a grapplable surface when the [member _hook] reaches it,
## the hook will act as if the grapplable surface didn't move.
## [br][br]
## While attached, the user will not be able to go beyond the distance between
## them and the attachment point at the time of attachment.
## [br][br]
## Recall the grapple at any time with [method startRecall].
## [br][br]
## Comes with the following SFX events:[br]
## - [code]extending[/code]:  plays when the hook is extending.[br]
## - [code]hitFail[/code]:  plays when the hook hits an ungrappleable target.[br]
## - [code]hitSuccess[/code]:  plays when the hook hits a grappleable target.[br]
## - [code]maxRangeReached[/code]:  plays when the hook reaches its max throw range.[br]
## - [code]recall[/code]:  plays when the hook is being recalled.[br]
## - [code]recallFinish[/code]:  plays when the hook is finished recalling.[br]
## - [code]recallStart[/code]:  plays when the hook is beginning to be recalled.[br]
## - [code]throw[/code]:  plays when the user throws the grappling hook.[br]

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the hook gets attached to a grapplable.
signal hook_attached()
## Emitted when the hook gets detached from a grapplable.
signal hook_detached()

# ------------------------------------------------
# enums
# ------------------------------------------------
## The various states the grappling hook can be in.
enum GrappleHookState {
	IDLE,       ## Doing nothing.
	TRAVELING,  ## Was thrown and now moving.
	RECALLING,  ## Returning to it's owner.
	ATTACHED    ## Currently attached to a point.
}

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]
## A reference to the grappling hook's target [Marker3D].
const _END_POINT = preload("uid://bqy7naymjdg4")

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The [RayCast3D] that determines where to throw the grappling hook.
@export var raycast:RayCast3D:
	set(newRaycast):
		raycast = newRaycast
		update_configuration_warnings()
## The location where the grappling hook is thrown from.
@export var throwOrigin:Marker3D:
	set(newOrigin):
		throwOrigin = newOrigin
		update_configuration_warnings()
## How fast the grappling hook moves when shot.  Can not be lower than 0.
@export var shootSpeed:float = 60.0:
	set(newSpeed):
		shootSpeed = max(0, newSpeed)
## How fast the grappling hook moves when recalled.  Can not be lower than 0.
@export var recallSpeed:float = 100:
	set(newSpeed):
		recallSpeed = max(0, newSpeed)
## The max range the grappling hook can be sent.  Can not be lower than 0.
@export var maxRange:float = 20.0:
	set(newRange):
		maxRange = max(0, newRange)
## How much an input direction affects the user's velocity while swinging.
@export var swingInfluenceForce:float = 6.0
## The maximum speed the user can build up while swinging.  Can not be lower than 0.
@export var maxSwingSpeed:float = 20.0:
	set(newSpeed):
		maxSwingSpeed = max(0, newSpeed)

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The visual for the line to the grapple point.
@onready var _line:MeshInstance3D = %Line
## [b]Internal-use only.[/b]
## The visual for the hook at the grapple point.
@onready var _hook:MeshInstance3D = %Hook
## Handles SFX events.
@onready var sfxEventHandler:SfxEventHandler = %SfxEventHandler

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## If this grappling hook can be used or not.
var enabled:bool = true
## If all components of the grappling hook are visible or not.
var visible:bool = false:
	set(newState):
		visible = newState
		_hook.visible = newState
		_line.visible = newState
## The current state of the hook.
var currentHookState:GrappleHookState = GrappleHookState.IDLE

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The location the hook will go to, even if it's not on a grapplable.
## Is set to a version of [member _END_POINT] in [method _ready()].
var _target:Marker3D
## [b]Internal-use only.[/b]
## The point in space where the hook is attached.
## Is usually just the global position of [member _target].
var _attachPoint:Vector3 = Vector3.ZERO
## [b]Internal-use only.[/b]
## If the thing the hook hit is grapplable.
var _targetIsGrapplable:bool = false
## [b]Internal-use only.[/b]
## The distance between [member throwOrigin] and [member _attachPoint].
var _currentMaxLength:float = 0.0

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	reset()
	raycast.target_position.z = -maxRange

	var endPoint:Marker3D = _END_POINT.instantiate()
	get_tree().root.add_child.call_deferred(endPoint)
	_target = endPoint

func _process(delta:float) -> void:
	if Engine.is_editor_hint():
		return

	_handleHookState(delta)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Applies grapple physics to a given velocity.
## [br][br]
## [code]delta[/code] is the physics process delta.[br]
## [code]velocity[/code] is the velocity to modify.[br]
## [code]inputDirRelative[/code] is a unit vector representing the direction
## to apply [member swingInfluenceForce].
## [codeblock]
## var grapplingHook:GrapplingHook = # path/reference to a GrapplingHook scene.
## var myVelocity:Vector3 = Vector3.ZERO
## var inputDirection:Vector3 = Vector3(1, 0, 0)
## func _physics_process(delta:float) -> void:
## 	# swing in the positive X direction
## 	myVelocity = grapplingHook.applyGrapplePhysics(delta, myVelocity, inputDirection)
## [/codeblock]
func applyGrapplePhysics(delta:float, velocity:Vector3, inputDirRelative:Vector3) -> Vector3:
	var hookAttachDisplacement:Vector3 = _attachPoint - owner.global_position
	var distanceToHook:float = hookAttachDisplacement.length()
	if distanceToHook <= 0.01:
		return velocity
	var hookAttachDirection:Vector3 = hookAttachDisplacement.normalized()

	if inputDirRelative.length() > 0.01:
		velocity += inputDirRelative * swingInfluenceForce * delta

	# If rope is stretched, constrain user to rope length
	if distanceToHook > _currentMaxLength:
		var away_velocity:float = velocity.dot(-hookAttachDirection)
		# remove velocity moving farther away from hook
		if away_velocity > 0.0:
			velocity -= (-hookAttachDirection) * away_velocity
		# correct position back onto rope sphere
		owner.global_position = _attachPoint - hookAttachDirection * _currentMaxLength

	# Set velocity to max it if exceeds it
	return _capVelocity(velocity)

## Determines if a given node or its parents are ungrappleable.
func isUngrapplable(node:Node) -> bool:
	while node != null:
		if node.is_in_group("Ungrappleable"):
			return true
		node = node.get_parent()
	return false

## Determines if the [member raycast] is hitting a grapplable target.
func raycastCollidingWithValidTarget() -> bool:
	if raycast.is_colliding():
		var hit:Node = raycast.get_collider()
		return not isUngrapplable(hit)
	return false

## Throws the [member _hook] out from [member throwOrigin].
func throwHook() -> void:
	if not enabled or currentHookState != GrappleHookState.IDLE:
		return

	_target.isInAir = not raycast.is_colliding()
	if _target.isInAir:
		_target.global_position = raycast.to_global(raycast.position + raycast.target_position)
	else:
		_target.global_position = raycast.get_collision_point()

	_targetIsGrapplable = raycastCollidingWithValidTarget()
	_hook.global_position = throwOrigin.global_position
	currentHookState = GrappleHookState.TRAVELING
	visible = true

	sfxEventHandler.play("throw")

## Starts the process of returning the [member _hook] to its owner.
## Only works if the hook is not idle or already recalling.
func startRecall() -> void:
	if currentHookState in [GrappleHookState.IDLE, GrappleHookState.RECALLING]:
		return

	_targetIsGrapplable = false
	currentHookState = GrappleHookState.RECALLING
	hook_detached.emit()

	sfxEventHandler.play("recallStart")

## Resets this to its initial state.
func reset() -> void:
	hook_detached.emit()
	currentHookState = GrappleHookState.IDLE
	_targetIsGrapplable = false
	_attachPoint = Vector3.ZERO
	_currentMaxLength = 0.0
	visible = false

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles the state of the [member _hook].
func _handleHookState(delta:float) -> void:
	var start := throwOrigin.global_position

	match currentHookState:
		GrappleHookState.TRAVELING:
			_hook.global_position = _hook.global_position.move_toward(_target.global_position, shootSpeed * delta)

			if not sfxEventHandler.getPlayerForEvent("extending").playing:
				sfxEventHandler.play("extending")
			_updateLineVisual(start, _hook.global_position)

			# When hook reaches target
			if _hook.global_position.distance_to(_target.global_position) <= 0.05:
				sfxEventHandler.stop("extending")
				if _targetIsGrapplable:
					sfxEventHandler.play("hitSuccess")
					_attachHook(_target.global_position)
				else:
					if _target.isInAir:
						sfxEventHandler.play("maxRangeReached")
					else:
						sfxEventHandler.play("hitFail")
					currentHookState = GrappleHookState.RECALLING

		GrappleHookState.ATTACHED:
			_updateLineVisual(start, _hook.global_position)

		GrappleHookState.RECALLING:
			_hook.global_position = _hook.global_position.move_toward(start, recallSpeed * delta)

			if not sfxEventHandler.getPlayerForEvent("recall").playing:
				sfxEventHandler.play("recall")
			_updateLineVisual(start, _hook.global_position)

			# When hook reaches owner
			if _hook.global_position.distance_to(start) <= 0.05:
				sfxEventHandler.stop("recall")
				reset()
				sfxEventHandler.play("recallFinish")

## [b]Internal-use only.[/b]
## Makes the line stretch between two points.
func _updateLineVisual(start:Vector3, end:Vector3) -> void:
	var dir := end - start
	var length := dir.length()
	if length <= 0.01:
		return
	var mid := start + dir * 0.5

	_line.global_position = mid

	var cur_basis := Basis()
	cur_basis.y = dir.normalized()
	var side := cur_basis.y.cross(Vector3.FORWARD)
	if side.length() < 0.01:
		side = owner.basis.y.cross(Vector3.RIGHT)
	cur_basis.x = side.normalized()
	cur_basis.z = cur_basis.x.cross(cur_basis.y).normalized()
	_line.global_transform.basis = cur_basis
	_line.scale = Vector3(1.0, length, 1.0)

## [b]Internal-use only.[/b]
## Attach the grappling hook to a position.
func _attachHook(point:Vector3) -> void:
	_attachPoint = point
	_currentMaxLength = throwOrigin.global_position.distance_to(_attachPoint)
	_hook.global_position = _attachPoint
	currentHookState = GrappleHookState.ATTACHED

	hook_attached.emit()

## [b]Internal-use only.[/b]
## Cap the velocity of a given velocity.
func _capVelocity(velocity:Vector3) -> Vector3:
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if horizontal.length() > maxSwingSpeed:
		horizontal = horizontal.normalized() * maxSwingSpeed
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	return velocity

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Editor-use Only.[/b]
## Returns editor warnings depending on this thing's state.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if self != get_tree().edited_scene_root:
		if not raycast:
			warnings.push_back("Raycast is not set.")
		if not throwOrigin:
			warnings.push_back("Throw Origin is not set.")

	return warnings
