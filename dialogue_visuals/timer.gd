@tool
extends Node3D
class_name TimerBar

## Emitted when the timer runs out.
signal timeout

## Set to true when you want to start the timer.
@export var shouldCountdown:bool = false:
	set(value):
		shouldCountdown = value
		if value:
			visible = true
## The time required for the timer to end. This property can also be set every time "start()" is called.
@export var duration:float = 1.0
## The progress of the timer so far.
@export_range(0.0, 1.0) var progress:float = 1.0

## Holds a reference to the timer's visual bar.
@onready var bar:MeshInstance3D = $Bar

## The original size of the timer bar. Currently hardcoded.
const originalBarSize:Vector3 = Vector3(0.14, 2.42, 2.075)

## The amount of time passed since starting the timer.
var timeElapsed:float = 0.0:
	set(value):
		timeElapsed = value
		progress = 1 - timeElapsed / duration
		updateBar()

func _ready() -> void:
	# makes sure not to run code if in editor
	if Engine.is_editor_hint():
		return
	else:
		visible = false

func _process(delta: float) -> void:
	updateBar()
	
	if shouldCountdown:
		timeElapsed += delta
		if timeElapsed >= duration:
			stop()

## Starts the timer.
func start(timeSec:float = -1.0) -> void:
	if timeSec > 0.0:
		duration = timeSec
	shouldCountdown = true

## Pauses the timer.
func pause() -> void:
	shouldCountdown = false

# TODO:  maybe make a separate function for timing out, to match the normal timer's functionality.
## Stops the timer.
func stop() -> void:	
	if shouldCountdown == false:
		return
	
	shouldCountdown = false
	timeElapsed = 0
	visible = false
	emit_signal("timeout")

## Updates the size of the bar based on the timer's progress.
func updateBar() -> void:
	bar.mesh.size.z = originalBarSize.z * progress
	bar.position.z = originalBarSize.z/2 * (1-progress)
