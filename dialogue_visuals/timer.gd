@tool
extends Node3D
class_name TimerBar

signal timeout

@export var shouldCountdown:bool = false:
	set(value):
		shouldCountdown = value
		if value:
			visible = true
@export var duration:float = 1.0
@export_range(0.0, 1.0) var progress:float = 1.0

@onready var bar:MeshInstance3D = $Bar
var originalBarSize:Vector3 = Vector3(0.14, 2.42, 2.075)

var timeElapsed:float = 0.0:
	set(value):
		timeElapsed = value
		progress = 1 - timeElapsed / duration
		updateBar()

func _ready() -> void:
	# makes sure not to run code if in editor
	if Engine.is_editor_hint():
		return
	
	visible = false

func _process(delta: float) -> void:
	updateBar()
	
	if shouldCountdown:
		timeElapsed += delta
		if timeElapsed >= duration:
			stop()

func start() -> void:
	shouldCountdown = true

func pause() -> void:
	shouldCountdown = false

func stop() -> void:	
	if shouldCountdown == false:
		return
	
	shouldCountdown = false
	timeElapsed = 0
	visible = false
	emit_signal("timeout")

func updateBar() -> void:
	bar.mesh.size.z = originalBarSize.z * progress
	bar.position.z = originalBarSize.z/2 * (1-progress)
