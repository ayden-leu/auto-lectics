extends Control

var current_npc_id := ""

var npc_data := {
	"npc_test_1": {
		"correct_name": "Aster",
		"name_unlocked": false,
		"notes": ""
	},
	"npc_test_2": {
		"correct_name": "Mira",
		"name_unlocked": false,
		"notes": ""
	},
	"npc_test_3": {
		"correct_name": "Orin",
		"name_unlocked": false,
		"notes": ""
	}
}

@onready var npc_container = $MainPanel/NPCListPanel/NPCNodeContainer
@onready var detail_panel = $MainPanel/DetailPanel
@onready var name_input_panel = $MainPanel/DetailPanel/NameInputPanel
@onready var notes_panel = $MainPanel/DetailPanel/NotesPanel

@onready var name_line_edit = $MainPanel/DetailPanel/NameInputPanel/LineEdit
@onready var submit_button = $MainPanel/DetailPanel/NameInputPanel/submitButton
@onready var notes_text_edit = $MainPanel/DetailPanel/NotesPanel/TextEdit

@onready var close_button = $MainPanel/CloseButton

var is_loading_notes := false

func _ready() -> void:
	add_to_group("blueprint_menu")

	hide()
	name_input_panel.hide()
	notes_panel.hide()

	_connect_npc_entries()
	_refresh_all_entries()

	submit_button.pressed.connect(_on_submit_name_pressed)
	notes_text_edit.text_changed.connect(_on_notes_changed)
	close_button.pressed.connect(_on_close_pressed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_blueprint"):
		if visible:
			close_menu()
		else:
			open_menu()

func _connect_npc_entries() -> void:
	for child in npc_container.get_children():
		if child.has_signal("selected"):
			if not child.selected.is_connected(_on_npc_selected):
				child.selected.connect(_on_npc_selected)

func _refresh_all_entries() -> void:
	for child in npc_container.get_children():
		if not child.has_method("set_locked"):
			continue

		var id = child.npc_id
		if not npc_data.has(id):
			continue

		if npc_data[id]["name_unlocked"]:
			child.set_unlocked_name(npc_data[id]["correct_name"])
		else:
			child.set_locked()

func _on_npc_selected(npc_id: String) -> void:
	current_npc_id = npc_id

	if not npc_data.has(npc_id):
		push_warning("No npc data found for id: " + npc_id)
		return

	# notes 永远显示
	notes_panel.show()

	is_loading_notes = true
	notes_text_edit.text = npc_data[npc_id]["notes"]
	is_loading_notes = false

	# 名字没解锁才显示输入框
	if npc_data[npc_id]["name_unlocked"]:
		name_input_panel.hide()
	else:
		name_input_panel.show()
		name_line_edit.text = ""

func _on_submit_name_pressed() -> void:
	if current_npc_id == "":
		return
	if not npc_data.has(current_npc_id):
		return

	var entered_name = name_line_edit.text.strip_edges()
	var correct_name = String(npc_data[current_npc_id]["correct_name"])

	if entered_name.to_lower() == correct_name.to_lower():
		npc_data[current_npc_id]["name_unlocked"] = true
		name_input_panel.hide()
		_refresh_all_entries()
	else:
		print("Incorrect name for ", current_npc_id)

func _on_notes_changed() -> void:
	if is_loading_notes:
		return
	if current_npc_id == "":
		return
	if not npc_data.has(current_npc_id):
		return

	npc_data[current_npc_id]["notes"] = notes_text_edit.text

func open_menu() -> void:
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func close_menu() -> void:
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_close_pressed() -> void:
	close_menu()
	
