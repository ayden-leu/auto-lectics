@tool
@icon("uid://c0agse6m0shng")
extends Area3D
class_name RestartLoopManagerArea3D
## An expanding [Area3D] trigger used by [LoopManager] to start a fancy loop reset when it reaches a [Player].
## [br][br]
## [b]Use Case[/b][br]
## Use this with [member LoopManager.fancyArea] when a loop reset should spread outward through the world instead of happening immediately.  The [LoopManager] calls [method startGrowing], waits for [signal collided_with_player], then finishes the fancy reset flow after the [Player] respawn sequence completes.
## [br][br]
## [b]How It Works[/b][br]
## The collision shape starts with a radius of [code]0.0[/code].  When [method startGrowing] is called, the shape radius increases every frame by [member growRate].  When a [Player]'s area enters this trigger, [signal collided_with_player] is emitted and the player runs its fancy respawn behavior.
## [br][br]
## [b]Resetting[/b][br]
## Call [method reset] to shrink the collision shape back to [code]0.0[/code] and return the area to its idle state.

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when a [Player] enters this area's collision shape.
## [br][br]
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
## [br][br]
## Larger values make the expanding trigger reach the [Player] sooner.  A value of [code]0.0[/code] means the area will not grow.
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
	collision.shape.radius = 0

## [b]Internal-use Only.[/b]
## Updates the area's current state every frame.
func _process(delta:float) -> void:
	_handleState(delta)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Makes the collision shape start growing outward.
## [br][br]
## This is normally called by [LoopManager] when a fancy reset begins.
func startGrowing() -> void:
	_currentState = State.GROW

## Shrinks the collision shape back to [code]0.0[/code] and returns this area to [constant IDLE].
## [br][br]
## This is normally called by [LoopManager] after the fancy reset finishes.
func reset() -> void:
	_currentState = State.RESET

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Handles the current growth state.
## [br][br]
## [constant GROW] increases [member collision]'s radius by [member growRate] each second.  [constant RESET] clears the radius and returns to [constant IDLE].
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
## [br][br]
## If the entering area's parent is a [Player], this emits [signal collided_with_player] and starts the player's fancy respawn behavior.
func _on_area_entered(area:Area3D) -> void:
	var areaOwner:Node3D = area.get_parent()
	if areaOwner is Player:
		areaOwner = areaOwner as Player
		collided_with_player.emit(areaOwner)
		areaOwner.respawnFancy()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Returns editor warnings for this area.
## [br][br]
## This currently returns no warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if get_tree().root != self:
		pass

	return warnings
