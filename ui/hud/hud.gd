extends Control

# TODO:  figure out where to actually place the HUD node.
#			currently, it's part of the PlayerCamera scene, but this makes it inaccessible to other nodes (unless you use workarounds)
#			should probably be part of the theorhetial "Scene Manager" node that we'll have to implement once we add menus.

@onready var crosshair:Sprite2D = %CrosshairSprite
@onready var player_camera: PlayerCamera = get_parent() as PlayerCamera

var crosshairSpriteNormal:Resource = preload("uid://dnfswnomwkg02")
var crosshairSpriteInteract:Resource = preload("uid://dtfn27ojmhrxx")

func _ready() -> void:
	$FadeRect.visible = false
	get_tree().root.size_changed.connect(_on_window_size_changed)

func _process(_delta: float) -> void:
	if not player_camera or not player_camera.focus:
		return
	
	# Hud currently gets player object from player camera.
	# If Hud is re-parented, this will need to be changed
	var player := player_camera.focus
	# Check if player can interact with something
	if player.interactionRaycast.is_colliding():
		_update_crosshair(true)
	else:
		_update_crosshair(false)

## Change crosshair color when interaction is possible.
func _update_crosshair(canInteract: bool) -> void:
	if canInteract:
		crosshair.texture = crosshairSpriteInteract
		return
	
	crosshair.texture = crosshairSpriteNormal

## Update the size of the HUD when the screen size changes
func _on_window_size_changed() -> void:
	var newSize:Vector2 = Globals.getScreenSize()
	#size = newSize
	#$ShaderOverlay.size = newSize
	#$CenterContainer.size = newSize
	#$FadeRect.size = newSize
