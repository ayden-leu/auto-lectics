@icon("uid://cb1q7neti54xl")
extends Area3D
class_name DeathPlane
## An out-of-bounds area that attempts to respawn bodies and owners of [Area3D]s that enter it.
##
## [b]Using:[/b][br]
## There are two ways to use this.
## [br][br]
## The first way involves just adding the pre-configured DeathPlane scene
## ([code]death_plane.tscn[/code]) to your environment.
## This will automatically give the DeathPlane a [WorldBoundaryShape3D] collision shape,
## which infinitely extends in the X and Z direction.
## [br][br]
## The second way involves just adding a DeathPlane node to your environment
## like you would with any other node.
## While this doesn't come with a [CollisionShape3D], it allows you to add one
## as a child without worrying about an infinitely big plane in the way.
## [br][br]
## You can add as many [CollisionShape3D] children nodes as you want, and colliding
## with any of them will cause this DeathPlane to do its thing.
## [br][br]
## When resizing the shape for your [CollisionShape3D], modify the shape's size fields
## and not the DeathPlane's transform fields.  Godot will give you a warning if you
## do a non-uniform scale so you should probably listen to it.
##
##
##
## [br][br][br]
## [b]Feature Brief:[/b][br]
## When a body or [Area3D] enters the [DeathPlane], this script checks whether that body has
## a [code]respawn()[/code] function. If it does, that function is called.
## This allows each body to define its own respawn behaviour, such as returning
## to its last grounded position or resetting to a default spawn point.
## [br][br]
## This script does not directly move the body. The body itself is responsible
## for implementing [code]respawn()[/code].
## [br][br]
## Make sure this [Area3D]'s collision mask can detect the bodies that should be
## respawned.
## For example, if its supposed to interact with [Player] characters, enable the
## Player/1 layer [i]mask[/i].  Setting the collision [i]layer[/i] won't affect
## this DeathPlane's functionality.

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## If the subject has a [code]respawn()[/code] function, that function is called.
## Otherwise, a warning is printed and nothing else happens.
func _performRespawn(subject:Node3D) -> void:
	if subject.has_method("respawn"):
		DebugHud.addToLog("DeathPlane:  Respawning [%s]." % subject.name)
		subject.respawn()
	else:
		DebugHud.addToLog("DeathPlane:  Body [%s] missing respawn() function." % subject.name, DebugHud.LogType.WARNING)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## Runs when a body enters this [DeathPlane].
func _on_body_entered(body:Node3D) -> void:
	_performRespawn(body)

## [b]Internal-use Only.[/b]
## Same as [method _on_body_entered], but for [Area3D]s.
func _on_area_entered(area:Area3D) -> void:
	print("area")
	_performRespawn(area.get_parent())

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
