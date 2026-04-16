@tool
extends Node
class_name LoopManager
## Establishes a loop system that "resets" all 

# TODO:  create a proper test scene to test functionality.
# TODO:  add export variable for fade overlay

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted immediately when the loop timer times out.
signal resetting()
## Emitted after the overlay fades in.
signal faded_in()
## Emitted after the overlay fades out.
signal faded_out()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The [ColorRect] that gets faded in and out whenever the loop resets.
@export var _overlay:ColorRect
## If the looping system should be handled externally or not.  Mainly for testing.
@export var manual:bool
## How long a loop lasts.  Default value = 10 minutes.
@export var loopDurationSeconds: float = 10 * 60
## How long it takes for the overlay to fade in.
@export var timeFadeOut: float = 0.6
## How long the overlay stays visible.
@export var timeHoldFade: float = 1.0
## How long it takes for the overlay to fade out.
@export var timeFadeIn: float = 0.6

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  The original alpha value of the screen overlay.  Gets set when the LoopManager is ready.
var _overlayAlphaVisible:float
## [b]Internal-use only.[/b]   If the loop is currently resetting or not.
var _loopBeingReset:bool = false
## The loop timer that ticks down.  See [mmethod _on_loop_timer_timeout] for what happens when it times out.
var _timer:Timer:
	set(value):
		if _timer == null:
			_timer = value
		else:
			value.queue_free()

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_overlayAlphaVisible = _overlay.color.a
	_overlay.color.a = 0
	_overlay.visible = true
	_connectSignals()
	_createLoopTimer()
	_configureTimer()
	
	if not manual:
		_timer.start()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Executes the resetting flow.
func performReset() -> void:
	#print("loop resetting")
	_loopBeingReset = true
	resetting.emit()
	await _fadeOverlay(true)
	
	#print("faded in")
	faded_in.emit()
	await get_tree().create_timer(timeHoldFade).timeout
	
	#print("fade held")
	await _fadeOverlay(false)
	
	#print("faded out")
	faded_out.emit()
	_loopBeingReset = false

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Creates the loop timer.  Shouldn't be ran externally.
func _createLoopTimer() -> void:
	_timer = Timer.new()
	add_child(_timer)

## [b]Internal-use only.[/b]  Configures the loop timer based on the export variables.
func _configureTimer() -> void:
	_timer.wait_time = loopDurationSeconds
	_timer.one_shot = true
	_timer.connect("timeout", _on_loop_timer_timeout)

## [b]Internal-use only.[/b]  Fades the darkening overlay in/out.  If the first parameter is true, it will fade the overlay in (visible).  If false, it will fade the overlay out (invisible).
func _fadeOverlay(fadingIn:bool) -> void:
	_overlay.visible = true
	var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	var finalVal:float = _overlayAlphaVisible if fadingIn else 0.0
	
	tween.tween_property(
		_overlay, "color:a", finalVal, timeFadeOut
	)
	
	await tween.finished

## [b]Internal-use only.[/b]  Connects all signals to all nodes who need to know about them.
func _connectSignals() -> void:
	var npcs:Array = get_tree().get_nodes_in_group("NPCs")
	for npc in npcs as Array[NPC]:
		faded_in.connect(npc._on_loop_manager_overlay_faded_in)
		faded_out.connect(npc._on_loop_manager_overlay_faded_out)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when the timer times out.
## When the loop timer times out, the screen will get darker, all NPCs will be "reset," and the screen darkness will go away.
func _on_loop_timer_timeout() -> void:
	performReset()
	_timer.start()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if self != get_tree().edited_scene_root:
		if _overlay == null:
			warnings.push_back("Overlay not assigned.")
	
	return warnings
