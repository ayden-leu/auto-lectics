@tool
extends DialogueWindow
class_name BlueprintWindow

# ------------------------------------------------
# signals
# ------------------------------------------------
signal npc_name_guessed_correctly(npcID:String)
signal unlock_condition_met(conditionID:String)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The number of correct name guesses needed
## before "unlocking" correctly guesssed NPC entries.
@export var _numNeededBeforeUnlocking: int = 3
@export var _npcEntriesPerPage: int = 2

# ------------------------------------------------
# onready variables
# ------------------------------------------------
@onready var _npcEntryHolder = %NPCEntryHolder
@onready var _details = %NpcDetailPanel
@onready var _guessNpcNamePanel = %GuessNpcNamePanel
@onready var _guessNpcNameField = %GuessNpcNameField
#@onready var _notesPanel = %NpcDetailPanel
@onready var _notesField = %NotesField
@onready var _portraitTextureRect: TextureRect = $Contents/NpcDetailPanel/Portrait

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

var _npcEntries:Array[BlueprintMenuNpcEntry] = []
var _idToIndex:Dictionary[String, int] = {}
var _selectedEntry:BlueprintMenuNpcEntry = null:
	set(newEntry):
		_selectedEntry = newEntry
		_details.visible = (newEntry != null)
var _currentPage:int = 0
var _loadingNotes := false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	windowType = "blueprint"
	headerText = "Blueprint"
	
	_loadEntries()
	_hideDetails()
	_updateEntryVisibility()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Stores the [BlueprintMenuNpcEntry]s in [member _npcEntryHolder] to [member _npcEntries].
## Can purppsly only be ran once.
func _loadEntries() -> void:
	if not _npcEntries.is_empty():
		return
	
	var index:int = 0
	for entry:BlueprintMenuNpcEntry in _npcEntryHolder.get_children():
		#entry.selected.connect(_on_npc_entry_selected)
		_npcEntries.push_back(entry)
		_idToIndex[entry.npcID] = index
		index += 1

## [b]Internal-use only.[/b]  Gets the [membere _npcEntries] index of a [BlueprintMenuNpcEntry].
func _getEntry(entryID:String) -> BlueprintMenuNpcEntry:
	if not _idToIndex.has(entryID):
		printerr("BlueprintMenu:  Could not find entry with ID: [" + entryID + "]")
		return null
	
	return _npcEntries[_idToIndex[entryID]]


## [b]Internal-use only.[/b]  Shows the NPC entry details.
func _showDetails() -> void:
	_loadNotes()
	_guessNpcNamePanel.visible = not _selectedEntry.unlocked
	
	if _selectedEntry.portraitTexture != null:
		_portraitTextureRect.texture = _selectedEntry.portraitTexture
	else:
		_portraitTextureRect.texture = null
	
	_details.visible = true


## [b]Internal-use only.[/b]  Hides the NPC entry details.
func _hideDetails() -> void:
	_details.visible = false


## [b]Internal-use only.[/b]  Loads notes for an NPC entry.
func _loadNotes() -> void:
	_loadingNotes = true
	_notesField.text = _selectedEntry.notes
	_loadingNotes = false


## [b]Internal-use only.[/b]  Determines if a given guess matches the name of the selected NPC entry.
func _determineIfGuessMatchesSelectedEntry(guess:String) -> void:
	var correctName:String = _selectedEntry.displayName
	if guess.to_lower() == correctName.to_lower():
		print("Correct name correctGuesses for ", _selectedEntry.npcID)
		_selectedEntry.nameGuessedCorrectly = true
		sfxEventHandler.play("entryGuessedCorrectly")
		npc_name_guessed_correctly.emit(_selectedEntry.npcID)
	else:
		print("Incorrect name for ", _selectedEntry.npcID)
		_selectedEntry.nameGuessedCorrectly = false
		sfxEventHandler.play("entryNameSubmitted")


## [b]Internal-use only.[/b]  "Unlocks" all NPC entries whose names were
## guessed correctly.
func _unlockCorrectGuesses() -> void:
	var correctGuesses:Array[BlueprintMenuNpcEntry] = []
	for entry:BlueprintMenuNpcEntry in _npcEntries:
		if entry.nameGuessedCorrectly:
			correctGuesses.append(entry)
	
	if correctGuesses.size() >= _numNeededBeforeUnlocking:
		for entry in correctGuesses:
			entry.unlock()


# Sending signal after engouh name correct
func _check_unlock_conditions() -> void:
	var check1 = _getEntry("npc_test_1")
	if not check1:
		return
	
	var check2 = _getEntry("npc_test_3")
	if not check2:
		return
	
	if check1.nameGuessedCorrectly and check2.nameGuessedCorrectly:
		print("Door_A can now open")
		unlock_condition_met.emit("Door_A")


## Updates the visibility of each NPC entry based on if they fit the page or not.
## Might be updated in the future.
func _updateEntryVisibility() -> void:
	var start_index = _currentPage * _npcEntriesPerPage
	var end_index = start_index + _npcEntriesPerPage
	
	for i in range(_npcEntryHolder.get_child_count()):
		var child = _npcEntryHolder.get_child(i)
		child.visible = i >= start_index and i < end_index


# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when an NPC entry is selected.
func _on_npc_entry_selected(entry:BlueprintMenuNpcEntry) -> void:
	sfxEventHandler.play("buttonPressed")
	print("Selected NPC from menu: ", entry.npcID)
	_selectedEntry = entry
	_showDetails()


## [b]Internal-use only.[/b]  Handles logic for when an NPC entry name is submitted.
func _on_npc_entry_name_submission() -> void:
	if _selectedEntry == null:
		return
	if _selectedEntry.unlocked:
		return
	
	var submittedName:String = _guessNpcNameField.text.strip_edges()
	_guessNpcNameField.text = ""
	if submittedName == "":
		return
	_selectedEntry.displayedName = submittedName
	
	_determineIfGuessMatchesSelectedEntry(submittedName)
	_unlockCorrectGuesses()
	_check_unlock_conditions()
	_showDetails()


## [b]Internal-use only.[/b]  Handles logic for when notes are entered for an NPC entry.
func _on_notes_field_text_changed() -> void:
	if _loadingNotes:
		return
	if _selectedEntry == null:
		return
	sfxEventHandler.play("notesFieldTextUpdated")
	
	_selectedEntry.notes = _notesField.text


func _on_guess_npc_name_field_text_changed(_new_text: String) -> void:
	sfxEventHandler.play("guessNpcNameTextChanged")


## [b]Internal-use only.[/b]  Handles logic for when the previous page button is pressed.
func _on_prev_page_button_pressed() -> void:
	sfxEventHandler.play("buttonPressed")
	if _currentPage > 0:
		_currentPage -= 1
		_updateEntryVisibility()


## [b]Internal-use only.[/b]  Handles logic for whene the next page button is pressed.
func _on_next_page_button_pressed() -> void:
	sfxEventHandler.play("buttonPressed")
	var max_page = int(ceil(float(_npcEntries.size()) / _npcEntriesPerPage)) - 1
	if _currentPage < max_page:
		_currentPage += 1
		_updateEntryVisibility()


## [b]Internal-use only.[/b]  Handles logic for when the NPC entry details panel is closed.
func _on_close_detail_button_pressed() -> void:
	sfxEventHandler.play("buttonPressed")
	_selectedEntry = null
	_hideDetails()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
