extends Menu

# ------------------------------------------------
# signals
# ------------------------------------------------
signal npc_name_correct(npc_id: String)
signal unlock_condition_met(target_id: String)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
@export var _numNeededBeforeConfirmation: int = 3
@export var _npcEntriesPerPage: int = 2

# ------------------------------------------------
# onready variables
# ------------------------------------------------
@onready var _npcEntryHolder = %NpcEntryHolder
@onready var _guessNpcNamePanel = %GuessNpcNamePanel
@onready var _guessNpcNameField = %GuessNpcNameField
@onready var _notesPanel = %NotesPanel
@onready var _notesField = %NotesField

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
var _npc_data := {
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

var _currentNpcID := ""
var _currentPage:int = 0
var _loadingNotes := false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	id = "blueprint"
	pausesGame = false
	super()

	_connect_npc_entries()
	_refresh_all_entries()
	
	_update_page_visibility()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
func _connect_npc_entries() -> void:
	for child in _npcEntryHolder.get_children():
		print("Found child:", child.name)
		if child.has_signal("selected"):
			print("Connecting selected for:", child.name, " id=", child.npc_id)
			if not child.selected.is_connected(_on_npc_selected):
				child.selected.connect(_on_npc_selected)

func _refresh_all_entries() -> void:
	for child in _npcEntryHolder.get_children():
		if not child.has_method("set_revealed_name"):
			continue

		var id_npc = child.npc_id
		if not _npc_data.has(id_npc):
			continue

		var display_name = String(_npc_data[id_npc]["display_name"])

		if _npc_data[id_npc]["name_locked"]:
			child.set_confirmed_locked_name(display_name)
		else:
			child.set_revealed_name(display_name)

func _refresh_current_detail_panel() -> void:
	if _currentNpcID == "":
		_guessNpcNamePanel.hide()
		_notesPanel.hide()
		return

	if not _npc_data.has(_currentNpcID):
		_guessNpcNamePanel.hide()
		_notesPanel.hide()
		return

	_notesPanel.show()

	_loadingNotes = true
	_notesField.text = _npc_data[_currentNpcID]["notes"]
	_loadingNotes = false

	if _npc_data[_currentNpcID]["name_locked"]:
		_guessNpcNamePanel.hide()
	else:
		_guessNpcNamePanel.show()

# Confirmend if correct number reach the number assigned
func _confirmEntries() -> void:
	var confirmed_ids: Array[String] = []

	for id_npc in _npc_data.keys():
		if _npc_data[id_npc]["name_confirmed"]:
			confirmed_ids.append(id)

	if confirmed_ids.size() >= _numNeededBeforeConfirmation:
		for id_npc in confirmed_ids:
			_npc_data[id_npc]["name_locked"] = true

# Sending signal after engouh name correct
func _check_unlock_conditions() -> void:
	if _npc_data["npc_test_1"]["name_confirmed"] and _npc_data["npc_test_3"]["name_confirmed"]:
		print("Door_A can now open")
		unlock_condition_met.emit("Door_A")

func _update_page_visibility() -> void:
	var start_index = _currentPage * _npcEntriesPerPage
	var end_index = start_index + _npcEntriesPerPage

	for i in range(_npcEntryHolder.get_child_count()):
		var child = _npcEntryHolder.get_child(i)
		child.visible = i >= start_index and i < end_index

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_npc_selected(npc_id: String) -> void:
	print("Selected NPC from menu:", npc_id)
	_currentNpcID = npc_id
	_refresh_current_detail_panel()

func _on_submit_npc_name_button_pressed() -> void:
	if _currentNpcID == "":
		return
	if not _npc_data.has(_currentNpcID):
		return
	if _npc_data[_currentNpcID]["name_locked"]:
		return

	var entered_name = _guessNpcNameField.text.strip_edges()
	if entered_name == "":
		return

	var correct_name = String(_npc_data[_currentNpcID]["correct_name"])

	_npc_data[_currentNpcID]["display_name"] = entered_name

	if entered_name.to_lower() == correct_name.to_lower():
		_npc_data[_currentNpcID]["name_confirmed"] = true
		print("Correct name confirmed for ", _currentNpcID)
		npc_name_correct.emit(_currentNpcID)
	else:
		_npc_data[_currentNpcID]["name_confirmed"] = false
		print("Incorrect name for ", _currentNpcID)

	_confirmEntries()
	_check_unlock_conditions()
	_refresh_all_entries()
	_refresh_current_detail_panel()


func _on_notes_field_text_changed() -> void:
	if _loadingNotes:
		return
	if _currentNpcID == "":
		return
	if not _npc_data.has(_currentNpcID):
		return

	_npc_data[_currentNpcID]["notes"] = _notesField.text

func _on_prev_page_button_pressed() -> void:
	if _currentPage > 0:
		_currentPage -= 1
		_update_page_visibility()

func _on_next_page_button_pressed() -> void:
	var max_page = int(ceil(float(_npcEntryHolder.get_child_count()) / _npcEntriesPerPage)) - 1
	if _currentPage < max_page:
		_currentPage += 1
		_update_page_visibility()

func _on_close_button_pressed() -> void:
	super()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
