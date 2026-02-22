@tool
extends EditorPlugin

var dock: Control

func _enter_tree() -> void:
	# IMPORTANT: This must be a Control (your dock UI script)
	dock = preload("res://addons/dialogue_generator/dialogue_gen.gd").new()
	dock.name = "Dialogue Flow"
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)

func _exit_tree() -> void:
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
		dock = null
