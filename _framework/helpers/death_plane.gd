@icon("uid://cb1q7neti54xl")
extends Area3D
class_name DeathPlane
## An out-of-bounds area that attempts to respawn bodies that enter it.
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
## When a body enters the [DeathPlane], this script checks whether that body has
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
## Player/1 layer mask.

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

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Runs when a body collides with this DeathPlane's collision shape(s).
## [br][br]
## If the body has a [code]respawn()[/code] function, that function is called.
## Otherwise, a warning is printed and nothing else happens.
func _on_body_entered(body:Node) -> void:
	if body.has_method("respawn"):
		body.respawn()
	else:
		DebugHud.addToLog("DeathPlane: Body [" + body.name + "] missing respawn() function.", DebugHud.LogType.WARNING)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
