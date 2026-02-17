@icon("uid://4k8rw8ox10br")
@tool
extends Node3D
class_name NPC
## The base class of all NPCs in the game.  

## The ways an [NPC] can follow a [member patrolPath].
enum PATH_FOLLOW_METHOD {
	LOOP,  ## When this [NPC] reaches the last point on the [member patrolPath], it will go to the starting point on the [member patrolPath] directly.
	PING_PONG  ## When this [NPC] reaches the last point on the [member patrolPath], it will turn around and follow the [member patrolPath] in reverse.
}

## The main model of the NPC.  Not used for anything in the base NPC class, but may be used in classes or scripts that extend the NPC class.
@export var model:Node3D
## The name of the NPC.  Not used for anything in the base NPC class, but may be used in classes that extend the NPC class.
@export var myName:String = ""

## If this [NPC] should start patrolling.
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
@export var pathFollowMode:PATH_FOLLOW_METHOD:
	set(value):
		pathFollowMode = value
		notify_property_list_changed()
## If [member pathFollowMode] is set to [constant PING_PONG] and this [NPC] reaches the end of the path, it will wait this long in seconds before traversing the path backwards.
@export var waitAtEndDuration: float = 0.0
# unused, but could be helpful in the future
#@export var face_move_direction: bool = true

## The position that this [NPC] should look at.  Set to Vector3.ZERO if you don't want them to look at anything.  Cannot set to null due to [url]https://github.com/godotengine/godot-proposals/issues/162[/url]
var lookAtPosition:Vector3 = Vector3.ZERO
# Used to figure out the next position this NPC should go to along the patrolPath.
var _pathFollower: PathFollow3D
# Technically this can also modify the patrolSpeed, but it's only used for flipping the direction this NPC follows a path.
var _pathFollowDirection: float = 1.0
var _stopFollowingPath: bool = false

func _ready() -> void:
	add_to_group("NPCs")

	if Engine.is_editor_hint():
		return
	
	if patrolEnabled:
		_setup_path_follow()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if patrolEnabled and not _stopFollowingPath and patrolPath:
		_moveOnPath(delta)
	
	if lookAtPosition != Vector3.ZERO:
		_turnToLookAtPosition(delta)

func _setup_path_follow() -> void:
	if patrolPath == null:
		return
	
	# Create PathFollow3D child node
	_pathFollower = PathFollow3D.new()
	_pathFollower.loop = (pathFollowMode == PATH_FOLLOW_METHOD.LOOP)
	patrolPath.add_child(_pathFollower)
	
	# Start at closest point
	if patrolPath.curve:
		var offset := patrolPath.curve.get_closest_offset(patrolPath.to_local(global_position))
		_pathFollower.progress = offset
	else:
		_pathFollower.progress = 0.0

func _moveOnPath(delta:float) -> void:
	var curve_len := patrolPath.curve.get_baked_length()
	_pathFollower.progress += patrolSpeed * delta * _pathFollowDirection
	
	# Behavior when ping pong (going back and forth on path)
	if (pathFollowMode == PATH_FOLLOW_METHOD.PING_PONG):
		if _pathFollower.progress >= curve_len:
			_pathFollower.progress = curve_len
			_pathFollowDirection = -1.0
			_maybe_wait()
		elif _pathFollower.progress <= 0.0:
			_pathFollower.progress = 0.0
			_pathFollowDirection = 1.0
			_maybe_wait()
	
	# Behavior when on a closed curve w/ looping enabled
	elif (pathFollowMode == PATH_FOLLOW_METHOD.LOOP):
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

# Function to face whoever interacted with this [InteractableNPC]. Useful for moving NPCs.
func _turnToLookAtPosition(delta: float) -> void:
	var direction := lookAtPosition - global_position
	direction.y = 0.0
	
	direction = direction.normalized()
	var target_dir := atan2(-direction.x, -direction.z)
	
	rotation.y = lerp_angle(rotation.y, target_dir, 5 * delta)
	#rotation.y = target_dir
	#model.rotation.y = lerp_angle(model.rotation.y, target_dir, 5 * delta)

# Wait at end of path before going back, if wait time is declared
func _maybe_wait() -> void:
	if waitAtEndDuration <= 0.0:
		return
	
	_stopFollowingPath = true
	await get_tree().create_timer(waitAtEndDuration).timeout
	_stopFollowingPath = false




#function for reset
func reset_to_default() -> void:
	if isTalking:
		endDialogue(false)

	#  重置对话状态
	currentDialogueID = initialDialogueID
	hecticFailureDialogueID = ""

	if "has_talked_once" in self:
		has_talked_once = false



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
	
	if property.name in ["waitAtEndDuration"] and pathFollowMode != PATH_FOLLOW_METHOD.PING_PONG:
		property.usage = PROPERTY_USAGE_NO_EDITOR
