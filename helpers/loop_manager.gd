@tool
extends Node

# TODO:  create a proper test scene to test functionality.

## Emitted immediately when the loop timer times out.
signal resetting
## Emitted after the overlay fades in.
signal faded_in
## Emitted after the overlay fades out.
signal faded_out

## If the looping system should be handled externally or not.  Mainly for testing.
@export var manual:bool
## How long a loop lasts.  Default value = 10 minutes.
@export var loopDuration: float = 10 * 60
## How long it takes for the overlay to fade in.
@export var timeFadeOut: float = 0.6
## How long the overlay stays visible.
@export var timeHoldFade: float = 1.0
## How long it takes for the overlay to fade out.
@export var timeFadeIn: float = 0.6

## The original alpha value of the screen overlay.  Gets set when the LoopManager is ready.
var overlayAlphaVisible:float
## If the loop is currently resetting or not.
var loopBeingReset:bool = false

## The loop timer that ticks down.  See "_on_loop_timer_timeout()" for what happens when it times out.
var timer:Timer:
	set(value):
		if timer == null:
			timer = value
		else:
			value.queue_free()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	overlayAlphaVisible = getFadeOverlay().color.a
	getFadeOverlay().color.a = 0
	connectSignals()
	createLoopTimer()
	configureTimer()
	
	if not manual:
		timer.start()

## Creates the loop timer.  Shouldn't be ran externally.
func createLoopTimer() -> void:
	timer = Timer.new()
	add_child(timer)

## Configures the loop timer based on the export variables.
func configureTimer() -> void:
	timer.wait_time = loopDuration
	timer.one_shot = true
	timer.connect("timeout", _on_loop_timer_timeout)

## Gets the fade overlay node on the HUD.
func getFadeOverlay() -> ColorRect:
	# NOTE:  I feel there's a better way to do this, but I can't think of anything
	# 			with the current node configuration.  So this is fine.
	var arr := get_tree().get_nodes_in_group("FadeOverlay")
	if arr.size() == 0:
		return null
	return arr[0] as ColorRect

## Fades the darkening overlay in/out.  If the first parameter is true, it will fade the overlay in (visible).  If false, it will fade the overlay out (invisible).
func fadeOverlay(fadingIn:bool) -> void:
	getFadeOverlay().visible = true
	var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	var finalVal:float = overlayAlphaVisible if fadingIn else 0.0
	
	tween.tween_property(
		getFadeOverlay(), "color:a", finalVal, timeFadeOut
	)
	
	await tween.finished

## Connects all signals to all nodes who need to know about them.
func connectSignals() -> void:
	var npcs:Array = get_tree().get_nodes_in_group("NPCs")
	for npc in npcs as Array[InteractableNPC]:
		faded_in.connect(npc._on_hud_overlay_faded_in)
		faded_out.connect(npc._on_hud_overlay_faded_out)


## Handles logic for when the timer times out.  When the loop timer times out, the screen will get darker, all NPCs will be "reset," and the screen darkness will go away.
func _on_loop_timer_timeout() -> void:
	#print("loop resetting")
	loopBeingReset = true
	resetting.emit()
	await fadeOverlay(true)
	
	#print("faded in")
	faded_in.emit()
	await get_tree().create_timer(timeHoldFade).timeout
	
	#print("fade held")
	await fadeOverlay(false)
	
	#print("faded out")
	faded_out.emit()
	loopBeingReset = false
	timer.start()



# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if self != get_tree().edited_scene_root:
		if getFadeOverlay() == null:
			warnings.push_back("Couldn't find the FadeOverlay.  Does the HUD scene exist anywhere in the current scene?  It should be a child of the PlayerCamera node.")
	
	return warnings
