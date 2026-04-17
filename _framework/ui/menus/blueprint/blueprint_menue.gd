extends Control


signal npc_name_confirmed(npc_id: String)
signal unlock_condition_met(target_id: String)

var current_npc_id := ""
var current_page: int = 0

var npc_data := {
	"npc_test_1": {
		"correct_name": "Aster",
		"display_name": "???",
		"name_confirmed": false,
		"name_locked": false,
		"notes": ""
	},
	"npc_test_2": {
		"correct_name": "Mira",
		"display_name": "???",
		"name_confirmed": false,
		"name_locked": false,
		"notes": ""
	},
	"npc_test_3": {
		"correct_name": "Orin",
		"display_name": "???",
		"name_confirmed": false,
		"name_locked": false,
		"notes": ""
	}
}

@export var confirmation_threshold: int = 3
@export var entries_per_page: int = 2



@onready var prev_page_button = $MainPanel/PrevPageButton
@onready var next_page_button = $MainPanel/NextPageButton

@onready var npc_container = $MainPanel/NPCListPanel/NPCNodeContainer
@onready var detail_panel = $MainPanel/DetailPanel
@onready var name_input_panel = $MainPanel/DetailPanel/NameInputPanel
@onready var notes_panel = $MainPanel/DetailPanel/NotesPanel

@onready var name_line_edit = $MainPanel/DetailPanel/NameInputPanel/LineEdit
@onready var submit_button = $MainPanel/DetailPanel/NameInputPanel/submitButton
@onready var notes_text_edit = $MainPanel/DetailPanel/NotesPanel/TextEdit

@onready var close_button = $MainPanel/CloseButton

## TEMPORARY.  Needed for freezing the player when the mmenu is brought up.
@export var player:Player

var is_loading_notes := false


func _ready() -> void:
	print("Menu ready start")

	add_to_group("blueprint_menu")

	hide()
	name_input_panel.hide()
	notes_panel.hide()

	print("npc_container =", npc_container)
	print("submit_button =", submit_button)
	print("notes_text_edit =", notes_text_edit)
	print("close_button =", close_button)

	_connect_npc_entries()
	_refresh_all_entries()
	

	
	submit_button.pressed.connect(_on_submit_name_pressed)
	notes_text_edit.text_changed.connect(_on_notes_changed)
	close_button.pressed.connect(_on_close_pressed)
	
	prev_page_button.pressed.connect(_on_prev_page_pressed)
	next_page_button.pressed.connect(_on_next_page_pressed)
	_update_page_visibility()
	
	print("Menu ready done")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_blueprint"):
		if visible:
			close_menu()
		else:
			open_menu()


func _connect_npc_entries() -> void:
	for child in npc_container.get_children():
		print("Found child:", child.name)
		if child.has_signal("selected"):
			print("Connecting selected for:", child.name, " id=", child.npc_id)
			if not child.selected.is_connected(_on_npc_selected):
				child.selected.connect(_on_npc_selected)


func _refresh_all_entries() -> void:
	for child in npc_container.get_children():
		if not child.has_method("set_revealed_name"):
			continue

		var id = child.npc_id
		if not npc_data.has(id):
			continue

		var display_name = String(npc_data[id]["display_name"])

		if npc_data[id]["name_locked"]:
			child.set_confirmed_locked_name(display_name)
		else:
			child.set_revealed_name(display_name)


func _on_npc_selected(npc_id: String) -> void:
	print("Selected NPC from menu:", npc_id)
	current_npc_id = npc_id
	_refresh_current_detail_panel()


func _refresh_current_detail_panel() -> void:
	if current_npc_id == "":
		name_input_panel.hide()
		notes_panel.hide()
		return

	if not npc_data.has(current_npc_id):
		name_input_panel.hide()
		notes_panel.hide()
		return

	notes_panel.show()

	is_loading_notes = true
	notes_text_edit.text = npc_data[current_npc_id]["notes"]
	is_loading_notes = false

	if npc_data[current_npc_id]["name_locked"]:
		name_input_panel.hide()
	else:
		name_input_panel.show()
		
		
func _on_submit_name_pressed() -> void:
	if current_npc_id == "":
		return
	if not npc_data.has(current_npc_id):
		return
	if npc_data[current_npc_id]["name_locked"]:
		return

	var entered_name = name_line_edit.text.strip_edges()
	if entered_name == "":
		return

	var correct_name = String(npc_data[current_npc_id]["correct_name"])

	npc_data[current_npc_id]["display_name"] = entered_name

	if entered_name.to_lower() == correct_name.to_lower():
		npc_data[current_npc_id]["name_confirmed"] = true
		print("Correct name confirmed for ", current_npc_id)
		npc_name_confirmed.emit(current_npc_id)
	else:
		npc_data[current_npc_id]["name_confirmed"] = false
		print("Incorrect name for ", current_npc_id)

	_apply_confirmation_threshold()
	_check_unlock_conditions()
	_refresh_all_entries()
	_refresh_current_detail_panel()


# Confirmend if correct number reach the number assigned
func _apply_confirmation_threshold() -> void:
	var confirmed_ids: Array[String] = []

	for id in npc_data.keys():
		if npc_data[id]["name_confirmed"]:
			confirmed_ids.append(id)

	if confirmed_ids.size() >= confirmation_threshold:
		for id in confirmed_ids:
			npc_data[id]["name_locked"] = true


# Sending signal after engouh name correct
func _check_unlock_conditions() -> void:
	if npc_data["npc_test_1"]["name_confirmed"] and npc_data["npc_test_3"]["name_confirmed"]:
		print("Door_A can now open")
		unlock_condition_met.emit("Door_A")
		
		
func _on_notes_changed() -> void:
	if is_loading_notes:
		return
	if current_npc_id == "":
		return
	if not npc_data.has(current_npc_id):
		return

	npc_data[current_npc_id]["notes"] = notes_text_edit.text


#func open_menu() -> void:
	#show()
	#print("showing blueprint menu")
	#InputHandler.hideCursor()
##	player.set_input_frozen(true)
#
#
#func close_menu() -> void:
	#hide()
	#print("hiding blueprint menu")
	#InputHandler.showCursor()
##	player.set_input_frozen(false)

func open_menu() -> void: 
	show() 
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
func close_menu() -> void: 
	hide() 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	#
	
func _on_close_pressed() -> void:
	print("Close button pressed")
	close_menu()

#_________________________________________________________________________________
#mutil page issue
func _on_prev_page_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		_update_page_visibility()

func _on_next_page_pressed() -> void:
	var max_page = int(ceil(float(npc_container.get_child_count()) / entries_per_page)) - 1
	if current_page < max_page:
		current_page += 1
		_update_page_visibility()

func _update_page_visibility() -> void:
	var start_index = current_page * entries_per_page
	var end_index = start_index + entries_per_page

	for i in range(npc_container.get_child_count()):
		var child = npc_container.get_child(i)
		child.visible = i >= start_index and i < end_index
#____________________________________________________________________________________________

# TEMPORARY    Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	
	if not player:
		warnings.push_back("The player field isn't set yet.")
	
	return warnings
