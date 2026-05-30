@tool
@icon("uid://kqsaeirnco0d")
extends Node
class_name LoopManager
## "Resets" "everything" after a configurable time period, or if an [RestartLoopManagerArea3D] is entered.
##
## [b]Using:[/b][br]
## By default, upon being loaded, after [member loopDurationSeconds], the LoopManager will "reset" "everything."
## This process will repeat forever while it is loaded.
## [br][br]
## When it "resets" it fades in a black overlay, emits a signal, then fades out the black overlay.
## [br][br]
## "Everything" just consists of all [NPC]s.  Refer to [method NPC._on_loop_manager_do_reset]
## and [method NPC._on_loop_manager_reset_finished] to see what they do when the reset occurs.
## [br][br]
## You can get the time remaining til a reset occurs by referencing [member resetProgressSeconds]
## or [member resetProgressRatio].  The value of [member resetProgressRatio] will
## be [constant @GDScript.INF] if its a division by zero.
## [br][br][br]
## [b]Fancy Mode:[/b][br]
## There is an optional "fancy mode" that can be enabled by making [member fancy] [code]true[/code].
## [br][br]
## When enabled, a new [member fancyArea] export field will appear.  It must be set to
## a [RestartLoopManagerArea3D] node.  Refer to its documentation for its configuration.
## [br][br]
## Upon the reset event occuring, the LoopManager will run [member _fancyArea]'s
## [method RestartLoopManagerArea3D.startGrowing]
## [br][br][br]
## [b]Configuration:[/b][br]
## The time to fade-in, hold the fade, and fade-out can be configured with [member timeFadeIn],
## [member timeHoldFade], and [member timeFadeOut] respectively.
## [br][br]
## When [member manual] is [code]true[/code], the countdown doesn't start automatically
## and the reset has to be performed manually by running either [method performNormalReset]
## or [method performFancyReset].
## [codeblock]
## # Assumption:  you have a LoopManager named "MyLoopManager" as a child to your node
## $MyLoopManager.performNormalReset()
## $MyLoopManager.performFancyReset()
## [/codeblock]
## [method performNormalReset] will only work if this LoopManager has [member _overlay] set.
## [br][br]
## [method performFancyReset] will only work if this LoopManager is [member fancy]
## and [member fancyArea] is set.

# TODO: remove faded_in and faded_out signals
# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted immediately when the loop timer times out or [method performReset] begins.
signal resetting()
## Emitted when the LoopManager actuallly performs the reset.
## Functionally the same as [signal faded_in] but with a different name.
signal do_reset()
## Emitted when the resetting process is finished.
## Functionally the same as [signal faded_out] but with a different name.
signal reset_finished()

## @deprecated
## Please use [signal do_reset] instead.[br]
## Emitted after the overlay has faded in and before [member timeHoldFade] begins.
signal faded_in()
## @deprecated
## Please use [signal reset_finished] instead.[br]
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
## [br]
## Its original alpha value is saved when the scene starts.
## The overlay is then set to transparent until a reset begins.
@export var _overlay:ColorRect
## If true, the loop timer does not start automatically and reset events must be
## started manually by either [method performNormalReset] or [method performFancyReset].
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
## A public reference to how much time is left before the reset occurs.
## Cannot be set.
var resetProgressSeconds:float:
	set(newValue):
		return
	get():
		return _timer.time_left

## Like [member resetProgressSeconds], but in a ratio format instead.
## (i.e a fraction between 0 and 1).
## Cannot be set.
var resetProgressRatio:float:
	set(newValue):
		return
	get():
		return _timer.time_left / _timer.wait_time

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## The original alpha value of [member _overlay], saved during [method _ready].
var _overlayAlphaVisible:float
## [b]Internal-use Only.[/b]
## If true, the reset event is currently running.
var _loopBeingReset:bool = false
## [b]Internal-use Only.[/b]
## The [Timer] that counts down to the next automatic reset.
## [br]
## See [method _on_loop_timer_timeout] for what happens when this timer expires.
var _timer:Timer:
	set(value):
		if _timer == null:
			_timer = value
		else:
			value.queue_free()
## [b]Internal-use Only.[/b]
## How long it actually takes for the overlay to fade out.
var _actualTimeFadeOut:float = 0.6
## [b]Internal-use Only.[/b]
## How long the overlay actually stays visible.
var _actualTimeHoldFade:float = 1.0
## [b]Internal-use Only.[/b]
## How long it actually takes for the overlay to fade in.
var _actualTimeFadeIn:float = 0.6

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# save and configure internal stuff
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

	# start the countdown if not in manual mode
	if not manual:
		_timer.start()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Executes the normal resetting flow.
## [br]
## Fade in overlay over [member _actualTimeFadeIn] seconds, performs the reset functions
## and waits for [member _actualTimeHoldFade] seconds, fades out overlay
## over [member _actualTimeFadeOut] seconds, then says its finished.
func performNormalReset() -> void:
	if not _overlay:
		DebugHud.addToLog("LoopManager:  Cannot do a normal reset if overlay is not set.", DebugHud.LogType.ERROR)
		return

	DebugHud.addToLog("LoopManager:  Starting reset process.  Fading in overlay.")
	_loopBeingReset = true
	resetting.emit()
	await _fadeOverlay(true)

	DebugHud.addToLog("LoopManager:  Overlay finished fading in, performing reset functions.")
	faded_in.emit()
	do_reset.emit()
	await get_tree().create_timer(_actualTimeHoldFade).timeout

	DebugHud.addToLog("LoopManager:  Fading overlay out.")
	await _fadeOverlay(false)

	DebugHud.addToLog("LoopManager:  Overlay finished fading out.  Reset process complete.", DebugHud.LogType.GOOD)
	faded_out.emit()
	reset_finished.emit()
	_loopBeingReset = false

## Executes the fancy resetting flow.
## [br]
## Makes [member fancyArea] start growing, waits for it to collide with a [Player],
## then performs the reset functions, then waits for the collided [Player] to respawn
## before saying its finished.
func performFancyReset() -> void:
	if not fancy:
		DebugHud.addToLog("LoopManager:  Cannot do a fancy reset if fancy isn't enabled.", DebugHud.LogType.ERROR)
		return
	elif not fancyArea:
		DebugHud.addToLog("LoopManager:  Cannot do a fancy reset if the fancyArea isn't set.", DebugHud.LogType.ERROR)
		return

	DebugHud.addToLog("LoopManager:  Starting fancy reset process.  Growing area.")
	_loopBeingReset = true
	resetting.emit()
	fancyArea.startGrowing()
	var player:Player = await fancyArea.collided_with_player

	DebugHud.addToLog("LoopManager:  Fancy area hit Player, performing reset functions.")
	do_reset.emit()
	await player.respawning_finished

	DebugHud.addToLog("LoopManager:  Player respawned, reset process complete.", DebugHud.LogType.GOOD)
	fancyArea.reset()
	reset_finished.emit()
	_loopBeingReset = false

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Creates the [Timer] used for automatic loop resets.
## [br]
## This should only be ran during setup.
func _createLoopTimer() -> void:
	_timer = Timer.new()
	add_child(_timer)

## [b]Internal-use Only.[/b]
## Configures [member _timer].
func _configureTimer() -> void:
	_timer.wait_time = loopDurationSeconds
	_timer.one_shot = true
	_timer.connect("timeout", _on_loop_timer_timeout)

## [b]Internal-use only.[/b]
## Fades [member _overlay] in/out.
## If [code]fadingIn[/code] is [code]true[/code], it will fade the overlay in (visible).
## Else, it will fade the overlay out (invisible).
func _fadeOverlay(fadingIn:bool) -> void:
	if not _overlay:
		DebugHud.addToLog("LoopManager:  Cannot fade overlay if overlay is not set.", DebugHud.LogType.ERROR)
		return

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
func _connectSignals() -> void:
	var npcs:Array = get_tree().get_nodes_in_group("NPCs")
	for npc in npcs as Array[NPC]:
		faded_in.connect(npc._on_loop_manager_overlay_faded_in)
		faded_out.connect(npc._on_loop_manager_overlay_faded_out)

		do_reset.connect(npc._on_loop_manager_do_reset)
		reset_finished.connect(npc._on_loop_manager_reset_finished)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use Only.[/b]
## Handles logic for when [member _timer] times out.
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
