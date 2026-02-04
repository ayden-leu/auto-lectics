@tool
extends Node3D
class_name WarningTile

@export var radius:float = 0.6

@onready var label:Label3D = $Background/TextLabel
@onready var background:MeshInstance3D = $Background
@onready var shakeTimer:Timer = $ShakeTimer

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var radiusToLabelPixelRatio:float = 0.005/0.6
var offsetRange:Dictionary = {
	"x": {
		"max": 0.03,
		"min": -0.03
	},
	"y": {
		"max": 0.03,
		"min": -0.03
	}
}
var shakeUpdateInterval:float = 0.1

func _ready() -> void:
	updateSize()
	shakeTimer.wait_time = shakeUpdateInterval
	shakeTimer.start()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		updateSize()

func updateSize() -> void:
	background.mesh.radius = radius
	label.pixel_size = radius * radiusToLabelPixelRatio

func shake() -> void:
	rng.randomize()
	var offsetX = rng.randf_range(offsetRange.x.min, offsetRange.x.max)
	var offsetY = rng.randf_range(offsetRange.y.min, offsetRange.y.max)
	
	background.position.y = offsetY * radius/0.6
	background.position.z = offsetX * radius/0.6


func _on_shake_timer_timeout() -> void:
	shake()
