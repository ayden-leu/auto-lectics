@icon("uid://4k8rw8ox10br")
@tool
extends Node3D
class_name NPC
## The base class of all NPCs in the game.

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------
## The ways an [NPC] can follow a [member patrolPath].
enum PathFollowMethod {
	LOOP,  ## When this [NPC] reaches the last point on the [member patrolPath], it will go to the starting point on the [member patrolPath] directly.
	PING_PONG  ## When this [NPC] reaches the last point on the [member patrolPath], it will turn around and follow the [member patrolPath] in reverse.
}

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The main model.  Not used for anything in the base NPC class, but may be used in classes or scripts that extend the NPC class.
@export var model:Node3D
## The name of the NPC.  Not used for anything in the base NPC class, but may be used in classes that extend the NPC class.
@export var myName:String = ""

## If this [NPC] should be able to move along its [member patrolPath].
@export var patrolEnabled: bool = false:
	set(value):
		patrolEnabled = value
		notify_property_list_changed()
@export_category("Patrolling")
## The path this [NPC] follows while patrolling.
@export var patrolPath: Path3D
## How fast this [NPC] should move along the [member patrolPath]. 
@export var patrolSpeed: float = 2.0
## How this [NPC] should patrol on its [member patrolPath].
@export var pathFollowMode:PathFollowMethod:
	set(value):
		pathFollowMode = value
		notify_property_list_changed()
## If [member pathFollowMode] is set to [constant PING_PONG] and this [NPC] reaches the end of the path, it will wait this long in seconds before traversing the path backwards.
@export var waitAtEndDuration: float = 0.0
## Unused and doesn't do anything.
@export var faceMoveDirection: bool = true

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## If true, this [NPC] will stop moving along its [member patrolPath].
var stopFollowingPath: bool = false
## The position that this [NPC] should look at.  Set to Vector3.ZERO if you don't want them to look at anything.  Cannot set to null due to [url]https://github.com/godotengine/godot-proposals/issues/162[/url]
var lookAtPosition:Vector3 = Vector3.ZERO

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Used to figure out the next position this [NPC] should go to along the [member patrolPath].
var _pathFollower: PathFollow3D
## [b]Internal-use only.[/b]  The direction along the [member patrolPath] this [NPC] should go.  1.0 means it goes "forward," -1.0 means it goes "backward."  Can also modify the [member patrolSpeed].
var _pathFollowDirection: float = 1.0

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	add_to_group("NPCs")

	if Engine.is_editor_hint():
		return
	
	if patrolEnabled:
		_setupPathFollow()

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

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Sets up stuff related to patrolling.
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

## [b]Internal-use only.[/b]  Moves this [NPC] along the [member patrolPath].
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

## [b]Internal-use only.[/b]  Turns this [NPC] to face the [member lookAtPosition].
func _turnToLookAtPosition(delta: float) -> void:
	var direction := lookAtPosition - global_position
	direction.y = 0.0
	
	direction = direction.normalized()
	var target_dir := atan2(-direction.x, -direction.z)
	
	rotation.y = lerp_angle(rotation.y, target_dir, 5 * delta)

## [b]Internal-use only.[/b]  If this [NPC] is moving along its [member patrolPath],
## this will make them stop for [member waitAtEndDuration] and then resume moving.
func _waitForAMoment() -> void:
	if waitAtEndDuration <= 0.0:
		return
	
	stopFollowingPath = true
	await get_tree().create_timer(waitAtEndDuration).timeout
	stopFollowingPath = false

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not model:
		warnings.push_back("This NPC doesn't have a model.")
	
	if myName == "":
		warnings.push_back("This NPC doesn't have a name yet.")
	
	return warnings

# Credit for how to do this:
# https://github.com/godotengine/godot-proposals/issues/1056
func _validate_property(property: Dictionary) -> void:
	if property.name in ["patrolPath", "patrolSpeed", "pathFollowMode", "waitAtEndDuration"] \
		and not patrolEnabled:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name in ["waitAtEndDuration"] and pathFollowMode != PathFollowMethod.PING_PONG:
		property.usage = PROPERTY_USAGE_NO_EDITOR
