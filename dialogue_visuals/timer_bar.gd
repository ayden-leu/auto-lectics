@tool
extends Node3D
class_name TimerBar
## A 3D representation of a timer.  Left is positive Z, right is negative Z.
## Make sure the mesh resource's "Local to Scene" property is enabled.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the time elapsed since starting is greater than or equal to the [member duration]
signal timeout()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
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
## The mesh that represents the timer bar.
@export var bar:MeshInstance3D

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The amount of time passed since starting the timer.
var timeElapsed:float = 0.0:
	set(value):
		timeElapsed = value
		progress = 1 - timeElapsed / duration
		_updateBar()

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  The original size of the timer bar. Currently hardcoded.
var _originalBarSize:Vector3

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _init() -> void:
	_originalBarSize = Vector3(0.14, 0.12, 2.075)

func _ready() -> void:
	# makes sure not to run code if in editor
	if Engine.is_editor_hint():
		return
	else:
		visible = false
	
	_originalBarSize = bar.mesh.size

func _process(delta: float) -> void:
	_updateBar()
	
	if shouldCountdown:
		timeElapsed += delta
		if timeElapsed >= duration:
			_timeout()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
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

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Ran when the the time elapsed is beyond the duration.
func _timeout() -> void:
	if not shouldCountdown:
		return
	
	stop()
	timeout.emit()

## [b]Internal-use only.[/b]  Updates the size of the bar based on the timer's progress.
func _updateBar() -> void:
	bar.mesh.size.z = _originalBarSize.z * progress
	bar.position.z = _originalBarSize.z/2 * (1-progress)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
