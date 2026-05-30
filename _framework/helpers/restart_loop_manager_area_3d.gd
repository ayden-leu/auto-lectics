@tool
@icon("uid://c0agse6m0shng")
extends Area3D
class_name RestartLoopManagerArea3D
## An expanding [Area3D] trigger used by [LoopManager] to start a fancy loop reset when it reaches a [Player].
##
## Use if you want to achieve that one effect from Outer Wilds.
## [br][br]
## [b]Using:[/b][br]
## Shouldn't be used directly, as [LoopManager] handles it.
## [br][br]
## [b]How it works:[/b][br]
## This area can be in multiple states.  Refer to [enum State] to get a general brief on them.
## [br][br]
## While [member _currentState] is [constant GROW], the shape radius of the collision area
## increases every frame by [member growRate].
## Once a [Player]'s area collides, the [signal collided_with_player] signal is emitted
## and the collided [Player]'s [method Player.respawnFancy] function is ran.

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when a [Player] enters this area's collision shape.
## [br]
## [param player] is the [Player] that entered the area.
signal collided_with_player(player:Player)

# ------------------------------------------------
# enums
# ------------------------------------------------
## The growth states this area can be in.
enum State {
	IDLE,   ## Doing nothing.
	GROW,   ## Increasing the radius of [member collision].
	RESET   ## Resetting [member collision] to its default size.
}

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## How fast the collision shape radius grows, in units per second.
## [br]
## Larger values make the expanding trigger reach the [Player] sooner.
## A value of [code]0.0[/code] means the area will not grow.
@export var growRate:float = 1.0

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## The [CollisionShape3D] whose radius is changed during the fancy reset flow.
@onready var collision:CollisionShape3D = %CollisionShape3D

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## The current state of this area.
var _currentState:State = State.IDLE

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Sets [member collision]'s radius to [code]0.0[/code] when the scene starts.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	collision.shape.radius = 0

## [b]Internal-use Only.[/b]
## Updates the area's current state every frame.
func _process(delta:float) -> void:
	if Engine.is_editor_hint():
		return
	_handleState(delta)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Makes the collision shape start growing outward.
## [br]
## This is normally called by [LoopManager] when a fancy reset begins.
func startGrowing() -> void:
	_currentState = State.GROW

## Shrinks the collision shape back to [code]0.0[/code] and returns this area to [constant IDLE].
## [br]
## This is normally called by [LoopManager] after the fancy reset finishes.
func reset() -> void:
	_currentState = State.RESET

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Handles the current growth state.
## [br]
## [constant GROW] increases [member collision]'s radius by [member growRate] each second.
## [br]
## [constant RESET] clears the radius and sets [member _currentState] to [constant IDLE].
func _handleState(delta:float) -> void:
	match _currentState:
		State.IDLE:
			pass
		State.GROW:
			collision.shape.radius += growRate * delta
		State.RESET:
			collision.shape.radius = 0
			_currentState = State.IDLE

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Handles logic for when another [Area3D] enters this trigger.
func _on_area_entered(area:Area3D) -> void:
	var areaOwner:Node3D = area.get_parent()
	if areaOwner is Player:
		areaOwner = areaOwner as Player
		collided_with_player.emit(areaOwner)
		areaOwner.respawnFancy()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Editor-use Only.[/b]
## Returns editor warnings depending on this thing's state.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if get_tree().root != self:
		pass

	return warnings
