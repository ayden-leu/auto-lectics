@tool
extends Area3D
class_name RestartLoopManagerArea3D
## The

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the [Player] enters this area's collision shape.
## [code]player[/code] is the aformentioned [Player].
signal collided_with_player(player:Player)

# ------------------------------------------------
# enums
# ------------------------------------------------
## The states this can be in.
enum State {
	IDLE,   # Doing nothing.
	GROW,   # Increasing the radius of the collision shape.
	RESET   # Resetting to the default size.
}

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## How fast the collision shape grows.
@export var growRate:float = 1.0

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## The collision area.
@onready var collision:CollisionShape3D = %CollisionShape3D
@onready var mesh:MeshInstance3D = %MeshInstance3D

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The current state of this area.
var _currentState:State = State.IDLE

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	collision.shape.radius = 0
	mesh.mesh.radius = 0.5 
	mesh.mesh.height = 1
	
	
func _process(delta:float) -> void:
	_handleState(delta)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Makes the collision shape start growing.
func startGrowing() -> void:
	_currentState = State.GROW
	
	
func reset() -> void:
	_currentState = State.RESET

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles the state of this area.
func _handleState(delta:float) -> void:
	match _currentState:
		State.IDLE:
			pass
		State.GROW:
			collision.shape.radius += growRate * delta
			mesh.mesh.radius += growRate * delta
			mesh.mesh.height += growRate * delta * 2
		State.RESET:
			collision.shape.radius = 0
			mesh.mesh.radius = 0
			mesh.mesh.height = 0
			_currentState = State.IDLE

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when an area enters this area.
func _on_area_entered(area:Area3D) -> void:
	var areaOwner:Node3D = area.get_parent()
	if areaOwner is Player:
		areaOwner = areaOwner as Player
		collided_with_player.emit(areaOwner)
		areaOwner.respawnFancy()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if get_tree().root != self:
		pass

	return warnings
