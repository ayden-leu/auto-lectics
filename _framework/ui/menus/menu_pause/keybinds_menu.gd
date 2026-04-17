extends PanelContainer

signal closed

@onready var scroll_container = $VBoxContainer/ScrollContainer
@onready var bindings_list = $VBoxContainer/ScrollContainer/BindingsList
@onready var back_button = $VBoxContainer/BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_populate_keybinds()


func _populate_keybinds() -> void:
	# Clear any existing entries
	for child in bindings_list.get_children():
		child.queue_free()

	var actions = InputMap.get_actions()

	for action in actions:
		# Skip built-in UI actions
		if action.begins_with("ui_"):
			continue

		var events = InputMap.action_get_events(action)
		var binding_text = _format_action_name(action) + ":  "

		if events.is_empty():
			binding_text += "(unbound)"
		else:
			var parts: Array[String] = []
			for event in events:
				parts.append(event.as_text())
			binding_text += " / ".join(parts)

		var label = Label.new()
		label.text = binding_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		bindings_list.add_child(label)

		# Divider between entries
		var sep = HSeparator.new()
		bindings_list.add_child(sep)


func _format_action_name(action: String) -> String:
	# Convert snake_case to Title Case: "jump_action" -> "Jump Action"
	return action.replace("_", " ").capitalize()


func _on_back_pressed() -> void:
	hide()
	closed.emit()
