@icon("uid://cb1q7neti54xl")
extends Area3D
class_name DeathPlane
## An out-of-bounds area that attempts to respawn bodies that enter it.
##
## To use, add this scene to a level and scale its collision shape so it covers
## any pit, fall zone, or out-of-bounds area where objects should be respawned.
## [br][br]
## When a body enters the [DeathPlane], this script checks whether that body has
## a [code]respawn()[/code] function. If it does, that function is called. This
## allows each body to define its own respawn behaviour, such as returning to its
## last grounded position or resetting to a default spawn point.
## [br][br]
## This script does not directly move the body. The body itself is responsible
## for implementing [code]respawn()[/code].
## [br][br]
## Make sure this [Area3D]'s collision mask can detect the bodies that should be
## respawned.

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
## [b]Internal-use Only.[/b]
## Connects the [signal Area3D.body_entered] signal to the collision handler.
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
## Runs when a body enters this [DeathPlane].
## [br][br]
## If the body has a [code]respawn()[/code] function, that function is called.
## Otherwise, a warning is printed and nothing else happens.
func _on_body_entered(body: Node) -> void:
	if body.has_method("respawn"):
		body.respawn()
	else:
		push_warning("DeathPlane: Body [", body.name, "] missing respawn() function.")

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
