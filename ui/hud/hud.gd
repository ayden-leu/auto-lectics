extends Control

# TODO:  actually code this because this is just quick and dirty
# TODO:  figure out where to actually place the HUD node.
#			currently, it's part of the PlayerCamera scene, but this makes it inaccessible to other nodes (unless you use workarounds)
#			should probably be part of the theorhetial "Scene Manager" node that we'll have to implement once we add menus.

@export var normal_color: Color = Color.WHITE
@export var highlight_color: Color = Color(0.3, 1.0, 0.3)

@onready var reticle: ColorRect = $CenterContainer/ColorRect2/ColorRect
@onready var player_camera: PlayerCamera = get_parent() as PlayerCamera

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not player_camera or not player_camera.focus:
		return
	
	# Hud currently gets player object from player camera.
	# If Hud is re-parented, this will need to be changed
	var player := player_camera.focus
	# Check if player can interact with something
	if player.interactionRaycast.is_colliding():
		_set_reticle_highlight(true)
	else:
		_set_reticle_highlight(false)

## Change reticle color when interaction is possible.
func _set_reticle_highlight(on: bool) -> void:
	reticle.color = highlight_color if on else normal_color
