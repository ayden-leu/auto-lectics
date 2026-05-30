@tool
@icon("uid://kqsaeirnco0d")
extends Node
class_name LoopManager
## "Resets" "everything" after a configurable time period, or if an [RestartLoopManagerArea3D] is entered.
##
## to write.
## but tl;dr after a configurable amount of time, the manager will reset everything.
## [br]
## unless it's in manual mode.  then outside code has to do the reset.
## [br]
## if it's in fancy mode, it'll make a [RestartLoopManagerArea3D] start to grow.
## when it collides with a [Player], then the reset process will happen.


# TODO:  create a proper test scene to test functionality.
# TODO:  add export variable for fade overlay

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted immediately when the loop timer times out or [method performReset] begins.
signal resetting()
## Emitted after the overlay has faded in and before [member timeHoldFade] begins.
signal faded_in()
## Emitted after the overlay has faded back out and the reset sequence is finished.
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
## The [ColorRect] faded in and out during the reset sequence.
## [br][br]
## Its original alpha value is saved when the scene starts.  The overlay is then set to transparent until a reset begins.
@export var _overlay:ColorRect
## If true, the loop timer does not start automatically.
## [br][br]
## Use this for tests, scripted events, or scenes where another system should decide when [method performReset] runs.
@export var manual:bool
## How long a loop lasts.  Default value = 10 minutes.
@export var loopDurationSeconds:float = 10 * 60
## How long it takes for the overlay to fade out.
@export var timeFadeOut:float = 0.6
## How long the overlay stays visible.
@export var timeHoldFade:float = 1.0
## How long it takes for the overlay to fade in.
@export var timeFadeIn:float = 0.6
## Whether to do the fancy [RestartLoopManagerArea3D] thing or not.
@export var fancy:bool:
	set(value):
		fancy = value
		notify_property_list_changed()
		update_configuration_warnings()

@export_group("Fancy Stuff")
## The fancy [RestartLoopManagerArea3D] thing.
@export var fancyArea:RestartLoopManagerArea3D:
	set(value):
		fancyArea = value
		notify_property_list_changed()
		update_configuration_warnings()
### How long it takes for the overlay to fade out.
#@export var fancyTimeFadeOut:float = 0.6
### How long the overlay stays visible.
#@export var fancyTimeHoldFade:float = 1.0
### How long it takes for the overlay to fade in.
#@export var fancyTimeFadeIn:float = 0.6

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## The original alpha value of [member _overlay], saved when this manager is ready.
var _overlayAlphaVisible:float
## [b]Internal-use Only.[/b]
## If true, the reset sequence is currently running.
var _loopBeingReset:bool = false
## [b]Internal-use Only.[/b]
## The [Timer] that counts down to the next automatic reset.
## [br][br]
## See [method _on_loop_timer_timeout] for what happens when this timer expires.
var _timer:Timer:
	set(value):
		if _timer == null:
			_timer = value
		else:
			value.queue_free()
## How long it actually takes for the overlay to fade out.
var _actualTimeFadeOut:float = 0.6
## How long the overlay actually stays visible.
var _actualTimeHoldFade:float = 1.0
## How long it actually takes for the overlay to fade in.
var _actualTimeFadeIn:float = 0.6

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Prepares the overlay, connects reset signals, creates the timer, and starts it when not in manual mode.
## [br][br]
## In the editor, this returns early so runtime-only timers and signal connections are not created.
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_overlayAlphaVisible = _overlay.color.a
	_overlay.color.a = 0
	_overlay.visible = true
	_connectSignals()
	_createLoopTimer()
	_configureTimer()

	#if fancy:
		#_actualTimeFadeIn = fancyTimeFadeIn
		#_actualTimeFadeOut = fancyTimeFadeOut
		#_actualTimeHoldFade = fancyTimeHoldFade
	#else:
	_actualTimeFadeIn = timeFadeIn
	_actualTimeFadeOut = timeFadeOut
	_actualTimeHoldFade = timeHoldFade

	if not manual:
		_timer.start()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Executes the normal resetting flow.
func performNormalReset() -> void:
	#print("loop resetting")
	_loopBeingReset = true
	resetting.emit()
	await _fadeOverlay(true)

	#print("faded in")
	faded_in.emit()
	await get_tree().create_timer(_actualTimeHoldFade).timeout

	#print("fade held")
	await _fadeOverlay(false)

	#print("faded out")
	faded_out.emit()
	_loopBeingReset = false


## Executes the fancy resetting flow.
func performFancyReset() -> void:
	#print("loop resetting")
	_loopBeingReset = true
	resetting.emit()
	fancyArea.startGrowing()
	var player:Player = await fancyArea.collided_with_player
	await player.respawning_finished

	player.respawnCheckpoint()
	fancyArea.reset()
	_loopBeingReset = false

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

## [b]Internal-use Only.[/b]
## Creates the [Timer] used for automatic loop resets.
## [br][br]
## This should only run during setup.
func _createLoopTimer() -> void:
	_timer = Timer.new()
	add_child(_timer)

## [b]Internal-use Only.[/b]
## Configures [member _timer] from the exported loop settings.
## [br][br]
## The timer waits for [member loopDurationSeconds], fires once, and calls [method _on_loop_timer_timeout] when it expires.

func _configureTimer() -> void:
	_timer.wait_time = loopDurationSeconds
	_timer.one_shot = true
	_timer.connect("timeout", _on_loop_timer_timeout)

## [b]Internal-use only.[/b]
## Fades the darkening overlay in/out.
## If the first parameter is true, it will fade the overlay in (visible).
## If false, it will fade the overlay out (invisible).

func _fadeOverlay(fadingIn:bool) -> void:
	_overlay.visible = true
	var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	var finalVal:float = _overlayAlphaVisible if fadingIn else 0.0

	if fadingIn:
		tween.tween_property(_overlay, "color:a", finalVal, _actualTimeFadeIn)
	else:
		tween.tween_property(_overlay, "color:a", finalVal, _actualTimeFadeOut)

	await tween.finished


## [b]Internal-use Only.[/b]
## Connects loop fade signals to every [NPC] currently in the [code]NPCs[/code] group.
## [br][br]
## [signal faded_in] connects to [method NPC._on_loop_manager_overlay_faded_in], and [signal faded_out] connects to [method NPC._on_loop_manager_overlay_faded_out].

func _connectSignals() -> void:
	var npcs:Array = get_tree().get_nodes_in_group("NPCs")
	for npc in npcs as Array[NPC]:
		faded_in.connect(npc._on_loop_manager_overlay_faded_in)
		faded_out.connect(npc._on_loop_manager_overlay_faded_out)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

## [b]Internal-use Only.[/b]
## Handles logic for when [member _timer] times out.
## [br][br]
## Runs [method performReset], then starts [member _timer] again so the next loop can begin.

func _on_loop_timer_timeout() -> void:
	if fancy:
		await performFancyReset()
	else:
		await performNormalReset()
	_timer.start()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Editor-use Only.[/b]
## Returns editor warnings depending on this thing's state.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if self != get_tree().edited_scene_root:
		if _overlay == null:
			warnings.push_back("Overlay not assigned.")
		if fancy and not fancyArea:
			warnings.push_back("Fancy area/RestartLoopManagerArea3D not set.")

	return warnings

## [b]Editor-use Only.[/b]
## Hides certain export fields depending on this thing's state.
func _validate_property(property: Dictionary) -> void:
	if property.name in ["Fancy Stuff", "fancyArea", "fancyTimeFadeOut", "fancyTimeHoldFade",
	"fancyTimeFadeIn"] and not fancy:
		property.usage = PROPERTY_USAGE_NO_EDITOR
