@tool
@icon("uid://d3bw2lwsbjpfb")
extends Control
class_name Crosshair
## Displays a crosshair in the center of the screen.
##
## The crosshair automatically changes appearance based on what the
## assigned [Player] is currently looking at.
## [br][br]
## To use, add the pre-built Crosshair scene ([code]crosshair.tscn[/code]) to a gameplay scene.
## Then assign the desired [Player] to [member player].
## [br][br]
## The crosshair listens for interaction and grappling signals emitted
## by the player and updates its appearance automatically.
## [br][br]
## The following crosshair states are supported:[br]
## - Normal: nothing special is being targeted.[br]
## - Interactable: the player is looking at an interactable object.[br]
## - Grappleable: the player is looking at a valid grappling target.
## [br][br]
## Interactable targets take priority over grappleable targets when
## determining which crosshair icon to display.

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## The sprite for the crosshair in its default state.
const SPRITE_NORMAL:Resource = preload("uid://dnfswnomwkg02")
## The sprite for the crosshair when over an interactable.
const SPRITE_INTERACTABLE:Resource = preload("uid://dtfn27ojmhrxx")
## The sprite for the crosshair when over a grapplable.
const SPRITE_GRAPPLEABLE:Resource = preload("uid://dr2qqbj4qmp0a")

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The [Player] this crosshair should monitor.
@export var player:Player

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## The crosshair sprite.
@onready var crosshair:Sprite2D = %CrosshairSprite

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## If the crosshair is over a grapplable at this moment.
var _grappleable:bool = false
## If the crosshair is over an interactable at this moment.
var _interactable:bool = false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	player.looking_at_interactable.connect(_on_player_looking_at_interactable)
	player.no_longer_looking_at_interactable.connect(_on_player_no_longer_looking_at_interactable)
	player.looking_at_grappleable.connect(_on_player_looking_at_grappleable)
	player.no_longer_looking_at_grappleable.connect(_on_player_no_longer_looking_at_grappleable)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Change crosshair color when interaction is possible.
func _update_crosshair() -> void:
	# in order of priority
	if _interactable:
		crosshair.texture = SPRITE_INTERACTABLE
	elif _grappleable:
		crosshair.texture = SPRITE_GRAPPLEABLE
	else:
		crosshair.texture = SPRITE_NORMAL

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when the player is looking at an interactable.
func _on_player_looking_at_interactable() -> void:
	_interactable = true
	_update_crosshair()

## [b]Internal-use only.[/b]
## Handles logic for when the player is no longer looking at an interactable.
func _on_player_no_longer_looking_at_interactable() -> void:
	_interactable = false
	_update_crosshair()

## [b]Internal-use only.[/b]
## Handles logic for when the player is no longer looking at a grappleable object.
func _on_player_looking_at_grappleable() -> void:
	_grappleable = true
	_update_crosshair()

## [b]Internal-use only.[/b]
## Handles logic for when the player is no longer looking at a grappleable object.
func _on_player_no_longer_looking_at_grappleable() -> void:
	_grappleable = false
	_update_crosshair()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Editor-use Only.[/b]
## Returns editor warnings depending on this thing's state.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if self != get_tree().edited_scene_root:
		if not player:
			warnings.push_back("Player is not set.")

	return warnings
