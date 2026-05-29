@icon("uid://4k8rw8ox10br")
@tool
extends Node3D
class_name NPC
## Base [Node3D] class for NPCs that need a name, model reference, optional patrolling, and loop-reset hooks.
## [br][br]
## [b]Use Case[/b][br]
## Use this for simple non-interactable NPCs, or extend it when building more specialized NPC types such as [InteractableNPC].  The base class registers itself in the [code]NPCs[/code] group so systems such as [LoopManager] can find, disable, reset, and enable all NPCs together.
## [br][br]
## [b]Patrolling[/b][br]
## When [member patrolEnabled] is true, this NPC follows [member patrolPath] at [member patrolSpeed] units per second.  [member pathFollowMode] controls whether the NPC loops back to the start or reverses direction at each end of the path.  A larger [member patrolSpeed] value makes the NPC move faster along the path.
## [br][br]
## [b]Facing Targets[/b][br]
## Set [member lookAtPosition] to make the NPC smoothly rotate toward a world-space position on the horizontal plane.  Set it to [constant Vector3.ZERO] when the NPC should stop trying to face a target.
## [br][br]
## [b]Extending This Class[/b][br]
## [method enable], [method disable], and [method reset] are intentionally empty in this base class.  Override them in child classes when an NPC needs custom state changes during loop transitions or gameplay events.

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------
## The ways an NPC can follow [member patrolPath].
enum PathFollowMethod {
	LOOP,      ## When this NPC reaches the last point on [member patrolPath], it wraps directly to the start of [member patrolPath].
	PING_PONG  ## When this NPC reaches the last point on [member patrolPath], it turns around and follows [member patrolPath] in reverse.
}

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The main model.
## Not used for anything in the base NPC class, but may be used in classes or scripts that extend the NPC class.
@export var model:Node3D
## The internal ID of this NPC.
## Used internally for other things.  Unused by the NPC class itself.
@export var internalID:String = ""
## The name of the NPC.
## Used when this NPC's name needs to be displayed for something.  Unused the NPC class itself.
@export var displayName:String = ""
## If true, this NPC can move along [member patrolPath].
## [br][br]
## Turning this off hides the patrolling export fields in the inspector and prevents path movement during gameplay.
@export var patrolEnabled: bool = false:
	set(value):
		patrolEnabled = value
		notify_property_list_changed()
@export_category("Patrolling")
## The [Path3D] this NPC follows while patrolling.
## [br][br]
## The NPC starts at the closest point on this path when patrolling is set up.  If [member patrolEnabled] is true and this is not assigned, the editor shows a configuration warning.
@export var patrolPath: Path3D:
	set(value):
		patrolPath = value
		notify_property_list_changed()

## How fast this NPC moves along [member patrolPath], in path units per second.
## [br][br]
## Larger values make the NPC move faster.  Negative values are not expected; use [member pathFollowMode] to choose how the NPC changes direction at the ends of the path.
@export var patrolSpeed: float = 2.0
## How this NPC behaves when it reaches the ends of [member patrolPath].
@export var pathFollowMode:PathFollowMethod:
	set(value):
		pathFollowMode = value
		notify_property_list_changed()
## How long, in seconds, this NPC waits before reversing direction at the end of [member patrolPath].
## [br][br]
## This only appears in the inspector when [member pathFollowMode] is [constant PING_PONG].  A value of [code]0.0[/code] means the NPC reverses immediately.
@export var waitAtEndDuration: float = 0.0
# Unused and doesn't do anything.
#@export var faceMoveDirection: bool = true

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## If true, this NPC pauses movement along [member patrolPath].
## [br][br]
## This is used internally while waiting at the end of a ping-pong patrol, but it can also be set by other scripts when path movement should temporarily pause.
var stopFollowingPath: bool = false
## The world-space position this NPC should turn toward.
## [br][br]
## Set this to [constant Vector3.ZERO] when the NPC should not look at anything.  This uses [constant Vector3.ZERO] instead of [code]null[/code] because typed [Vector3] values cannot be nullable.
var lookAtPosition:Vector3 = Vector3.ZERO

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Used to calculate the next position this NPC should move to along [member patrolPath].
var _pathFollower: PathFollow3D
## [b]Internal-use Only.[/b]
## The direction this NPC moves along [member patrolPath].  [code]1.0[/code] moves forward, and [code]-1.0[/code] moves backward.  This value is multiplied with [member patrolSpeed].
var _pathFollowDirection: float = 1.0

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Adds this NPC to the [code]NPCs[/code] group and sets up patrolling when the game starts.
## [br][br]
## In the editor, this returns early so tool-time updates do not create runtime-only [PathFollow3D] nodes.
func _ready() -> void:
	add_to_group("NPCs")

	if Engine.is_editor_hint():
		return

	if patrolEnabled:
		_setupPathFollow()

## [b]Internal-use Only.[/b]
## Updates path movement and look-at rotation every frame.
## [br][br]
## Patrolling only runs when [member patrolEnabled] is true, [member stopFollowingPath] is false, and [member patrolPath] is assigned.  Look-at rotation only runs when [member lookAtPosition] is not [constant Vector3.ZERO].
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if patrolEnabled and not stopFollowingPath and patrolPath:
		_moveOnPath(delta)

	if lookAtPosition != Vector3.ZERO:
		_turnToLookAtPosition(delta)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Enables this NPC.
## [br][br]
## This base implementation does nothing.  Override it in child classes when the NPC should restore collision, interaction, processing, visuals, or other gameplay state.
func enable() -> void:
	pass

## Disables this NPC.
## [br][br]
## This base implementation does nothing.  Override it in child classes when the NPC should temporarily stop collision, interaction, processing, visuals, or other gameplay state.

func disable() -> void:
	pass

## Resets this NPC to its default state.
## [br][br]
## This base implementation does nothing.  Override it in child classes when the NPC should clear conversation state, restore starting values, or otherwise prepare for a new loop.
func reset() -> void:
	pass

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Sets up runtime path-following for this NPC.
## [br][br]
## Creates a [PathFollow3D] under [member patrolPath], configures whether it loops, and places it at the path offset closest to this NPC's starting position.
func _setupPathFollow() -> void:
	if patrolPath == null:
		return

	# Create PathFollow3D child node
	_pathFollower = PathFollow3D.new()
	_pathFollower.loop = (pathFollowMode == PathFollowMethod.LOOP)
	patrolPath.add_child(_pathFollower)

	# Start at closest point
	if patrolPath.curve:
		var offset := patrolPath.curve.get_closest_offset(patrolPath.to_local(global_position))
		_pathFollower.progress = offset
	else:
		_pathFollower.progress = 0.0

## [b]Internal-use Only.[/b]
## Moves this NPC along [member patrolPath].
## [br][br]
## In [constant PING_PONG], the NPC clamps to each end of the path, reverses [member _pathFollowDirection], and waits for [member waitAtEndDuration] if needed.  In [constant LOOP], progress wraps around the path length.
func _moveOnPath(delta:float) -> void:
	var curve_len := patrolPath.curve.get_baked_length()
	_pathFollower.progress += patrolSpeed * delta * _pathFollowDirection

	# Behavior when ping pong (going back and forth on path)
	if (pathFollowMode == PathFollowMethod.PING_PONG):
		if _pathFollower.progress >= curve_len:
			_pathFollower.progress = curve_len
			_pathFollowDirection = -1.0
			_waitForAMoment()
		elif _pathFollower.progress <= 0.0:
			_pathFollower.progress = 0.0
			_pathFollowDirection = 1.0
			_waitForAMoment()

	# Behavior when on a closed curve w/ looping enabled
	elif (pathFollowMode == PathFollowMethod.LOOP):
		_pathFollower.progress = fposmod(_pathFollower.progress, curve_len)

	# Undefined behavior - follows path once to completion
	else:
		_pathFollower.progress = clamp(_pathFollower.progress, 0.0, curve_len)

	# Face forward on path
	lookAtPosition = _pathFollower.global_position

	# wait for this NPC to turn "forward"
	await get_tree().process_frame

	# Move NPC on path
	global_position = _pathFollower.global_position

## [b]Internal-use Only.[/b]
## Smoothly turns this NPC to face [member lookAtPosition] on the horizontal plane.
## [br][br]
## The vertical difference is ignored so the NPC rotates around the Y axis without pitching up or down.
func _turnToLookAtPosition(delta: float) -> void:
	var direction := lookAtPosition - global_position
	direction.y = 0.0

	direction = direction.normalized()
	var target_dir := atan2(-direction.x, -direction.z)

	rotation.y = lerp_angle(rotation.y, target_dir, 5 * delta)

## [b]Internal-use Only.[/b]
## Pauses this NPC's path movement for [member waitAtEndDuration].
## [br][br]
## This is used at the ends of a [constant PING_PONG] patrol.  If [member waitAtEndDuration] is [code]0.0[/code] or lower, the NPC keeps moving without waiting.
func _waitForAMoment() -> void:
	if waitAtEndDuration <= 0.0:
		return

	stopFollowingPath = true
	await get_tree().create_timer(waitAtEndDuration).timeout
	stopFollowingPath = false

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Handles logic for when the loop overlay finishes fading in.
## [br][br]
## Calls [method disable] and [method reset] so subclasses can stop interaction and restore their state during a loop transition.
func _on_loop_manager_overlay_faded_in() -> void:
	self.disable()
	self.reset()

## [b]Internal-use Only.[/b]
## Handles logic for when the loop overlay finishes fading out.
## [br][br]
## Calls [method enable] so subclasses can resume interaction or gameplay state after a loop transition.
func _on_loop_manager_overlay_faded_out() -> void:
	self.enable()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Returns editor warnings for missing NPC setup.
## [br][br]
## Warns when [member model] is missing, [member myName] is empty, or patrolling is enabled without an assigned [member patrolPath].
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if not model:
		warnings.push_back("This NPC doesn't have a model.")

	if internalID == "":
		warnings.push_back("This NPC doesn't have an internal ID yet.")

	if displayName == "":
		warnings.push_back("This NPC doesn't have a name yet.")

	if patrolEnabled:
		if not patrolPath and self != get_tree().edited_scene_root:
			warnings.push_back("This NPC can patrol but doesn't have a path set.")

	return warnings

# Credit for how to do this:
# https://github.com/godotengine/godot-proposals/issues/1056
## [b]Internal-use Only.[/b]
## Hides patrol-related properties in the inspector when they do not apply.
## [br][br]
## Patrolling fields are hidden when [member patrolEnabled] is false, and [member waitAtEndDuration] is hidden unless [member pathFollowMode] is [constant PING_PONG].
func _validate_property(property: Dictionary) -> void:
	if property.name in ["patrolPath", "patrolSpeed", "pathFollowMode", "waitAtEndDuration"] \
		and not patrolEnabled:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name in ["waitAtEndDuration"] and pathFollowMode != PathFollowMethod.PING_PONG:
		property.usage = PROPERTY_USAGE_NO_EDITOR
