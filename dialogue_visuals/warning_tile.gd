@tool
extends Node3D
class_name WarningTile

## Emitted when the warning tile detects it is blocking something important.
signal blocking_visual

## The radius of the warning tile from its center.
@export var radius:float = 0.6

## The text label of the warning tile. Usually says "WARNING"
@onready var label:Label3D = $Background/TextLabel
## Holds a refernece to the warning tile's background.
@onready var background:MeshInstance3D = $Background
## Holds a reference to the timer responsible for shaking the warning tile.
@onready var shakeTimer:Timer = $ShakeTimer
## Holds a reference to the area that detects if the warning tile is blocking something important.
@onready var visualArea:CollisionShape3D = $VisualArea/CollisionShape3D

## The mathematical relationship between the warning tile's radius and the label's pixel size.
const radiusToLabelPixelRatio:float = 0.005/0.6
## How often the warning tile visually shakes.
const shakeUpdateInterval:float = 0.1
## How far the warning tile can shake from its origin.
const offsetRange:Dictionary = {
	"x": 0.03,
	"y": 0.03
}

## A random number generator.
var rng:RandomNumberGenerator = RandomNumberGenerator.new()
## The number of times the warning tile has been moved due to blocking something important.
var numTimesRepositioned:int = 0

func _ready() -> void:
	updateSize()
	shakeTimer.wait_time = shakeUpdateInterval
	shakeTimer.start()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		updateSize()
		return

## Updates the size of the warning tile.
func updateSize() -> void:
	background.mesh.radius = radius
	label.pixel_size = radius * radiusToLabelPixelRatio
	visualArea.shape.size.x = (radius + offsetRange.x) * 2
	visualArea.shape.size.y = (radius + offsetRange.y) * 2

## Shakes the warning tile.
func shake() -> void:
	rng.randomize()
	var offsetX = rng.randf_range(-offsetRange.x, offsetRange.x)
	var offsetY = rng.randf_range(-offsetRange.y, offsetRange.y)
	
	background.position.x = offsetX * radius/0.6
	background.position.y = offsetY * radius/0.6

## Makes the warning tile look at the player's camera.
func lookAtCamera():
	if Engine.is_editor_hint():
		return
	look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)

## Kills the warning tile.
func kill() -> void:
	queue_free()


## Handles logic for when the shake timer times out.
func _on_shake_timer_timeout() -> void:
	shake()
	lookAtCamera()

## Handles logic for when the warning tile blocks something important.
func _on_visual_area_area_entered(_area: Area3D) -> void:
	emit_signal("blocking_visual", self)
