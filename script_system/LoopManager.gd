extends Node

@export var loop_length_seconds: float = 6.0  # 10 minutes
@export var fade_out_time: float = 0.6
@export var hold_dark_time: float = 1.0
@export var fade_in_time: float = 0.6

var time_elapsed: float = 0.0
var _looping: bool = false

func _process(delta: float) -> void:
	if _looping:
		return

	time_elapsed += delta
	if time_elapsed >= loop_length_seconds:
		time_elapsed = 0.0
		_run_loop()

func _get_fade_rect() -> ColorRect:
	var arr := get_tree().get_nodes_in_group("loop_fade")
	if arr.size() == 0:
		return null
	return arr[0] as ColorRect

func _run_loop() -> void:
	_looping = true
	push_warning("Loop: fade out")
	await _fade_to(1.0, fade_out_time)

	push_warning("Loop: hold")
	await get_tree().create_timer(hold_dark_time).timeout

	push_warning("Loop: reset npcs")
	reset_all_npcs()

	push_warning("Loop: fade in")
	await _fade_to(0.0, fade_in_time)

	push_warning("Loop: done")
	_looping = false

func _fade_to(alpha: float, duration: float) -> void:
	pass
	##kept crashing once we added the fog in 
	#var rect := _get_fade_rect()
	##if rect == null:
		##return
#
	#rect.visible = true
#
	#var target := rect.modulate
	#target.a = alpha
#
	#var t := get_tree().create_tween()
	#t.tween_property(rect, "modulate", target, duration)
	#await t.finished
#

func reset_all_npcs() -> void:
	var npcs = get_tree().get_nodes_in_group("npcs")
	for npc in npcs:
		if npc.has_method("reset_to_default"):
			npc.reset_to_default()
