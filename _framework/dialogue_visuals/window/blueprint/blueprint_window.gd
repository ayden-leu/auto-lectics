@tool
extends DialogueWindow
class_name BlueprintWindow
## A [DialogueWindow] that lets players keep notes on certain NPCs.
##
## [b]NPC Entries[/b][br]
## Each entry for an NPC will need to be added manually. You can do this by
## either duplicating an existing entry, or adding a new instance of [BlueprintMenuNpcEntry].
## Make sure the "selected" signal for each entry is connected to the this node's
## [method _on_npc_entry_selected] function.  If not, they'll be connected when the game runs
## but will output a debug message saying they arent.
## [br][br]
## Clicking on an [BlueprintMenuNpcEntry] will tell the [WindowManager] to spawn the [BlueprintNpcDetailWindow].
## [br][br]
## [b]Unlock Condition[/b][br]
## [method _checkUnlockConditions] only has a dummy unlock condition set at the moment.
## Be sure to modify it so the [signal unlock_condition_met] signal can properly do stuff.
## [br][br]
## [b]Styling[/b][br]
## When customizing the look, there are some things to consider on top of the
## other considerations described in [DialogueWindow].[br]
## 1) The order of each [BlueprintMenuNpcEntry] matters.  So if [npcEntriesPerPage] is 2 and there are 5 [BlueprintMenuNpcEntry]s, the first[br]
## two will be visible on page 0, the next two will be visible on page 1, and the last on page 2.[br]
## 2) The node type of [member _npcEntryHolder] doesn't have to be an [HFlowContainer], and can be any [Control] node type.
## [br][br]
## [b]SFX events[/b][br]
## Comes with the following optional SFX events, as well as the ones from [DialogueWindow]:[br]
## - buttonPressed:  plays when a button is presssed.[br]
## - entryGuessedCorrectly:  plays when an entry's name is guessed correctly.  Does not overlap with entryNameSubmitted.[br]
## - entryNameSubmitted:  plays when an entry's name is guessed.  Does not overlap with entryGuessedCorrectly.[br]

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the name entered by the player in the [BlueprintNpcDetailWindow]
## matches the display name of the currently selected [BlueprintMenuNpcEntry].
## [br][br]
## [code]npcID[/code] is the [member BlueprintMenuNpcEntry.npcID] of the selected [BlueprintMenuNpcEntry].
signal npc_name_guessed_correctly(npcID:String)
## Emitted when an unlock condition defined in [method _checkUnlockConditions] is met.
## [br][br]
## [code]conditionID[/code] is the ID of the condition unlocked.
signal unlock_condition_met(conditionID:String)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## The position on the screen where this initially spawns.
## Doesn't interfere with [WindowManager]'s position restoring.
const INITIAL_SPAWN_POSITION:Vector2 = Vector2(553.0, 112.0)

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The number of correct name guesses needed before setting
## correctly guesssed NPC entries as "unlocked."
@export var numNeededBeforeUnlocking:int = 3
## The number of [BlueprintMenuNpcEntry]s to display on one page.
## Modifying this value will update aspects in the editor view accordingly.
@export var npcEntriesPerPage:int = 2:
	set(newNum):
		npcEntriesPerPage = newNum
		if Engine.is_editor_hint():
			_updateEntryVisibility()
## The current page being displayed. Each page shows [member npcEntriesPerPage]
## amount of [BlueprintMenuNpcEntry]s.
## Modifying this value will update aspects in the editor view accordingly.
@export var currentPageNum:int = 0:
	set(newPageNum):
		currentPageNum = newPageNum
		if Engine.is_editor_hint():
			_updateEntryVisibility()

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The node that holds the [BlueprintMenuNpcEntry]s.
@onready var _npcEntryHolder:Control = %NPCEntryHolder

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Every [BlueprintMenuNpcEntry].
var _npcEntries:Array[BlueprintMenuNpcEntry] = []
## [b]Internal-use only.[/b]
## Maps [BlueprintMenuNpcEntry] IDs to their index in [member _npcEntries].
var _idToIndex:Dictionary[String, int] = {}
## [b]Internal-use only.[/b]
## The currently selected [BlueprintMenuNpcEntry].
var _selectedEntry:BlueprintMenuNpcEntry = null
## [b]Internal-use only.[/b]
## The current instance of [BlueprintNpcDetailWindow] created when [method _showDetails] runs.
var _detailWindow:BlueprintNpcDetailWindow = null

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	windowType = "blueprint"

	_loadEntries()
	_hideDetails()
	_updateEntryVisibility()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super(_delta)

func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	super(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Gets the state and info of each [BlueprintMenuNpcEntry].
## [br][br]
## The resulting dictionary is of the following format:
## [codeblock]
## {
## 	"some ID": {  # the entry's ID. rest of values are self-explanatory
## 		"displayedName": String value,
## 		"notes": String value,
## 		"nameGuessedCorrectly": bool value,
## 		"unlocked": bool value
## 	},
## 	"some other ID": { # the entry's ID. rest of values are self-explanatory
## 		"displayedName": String value,
## 		"notes": String value,
## 		"nameGuessedCorrectly": bool value,
## 		"unlocked": bool value
## 	}
## }
## [/codeblock]
func getState() -> Dictionary:
	print("BlueprintWindow:  Generating current state of entries.")
	var state: Dictionary = {}
	for entry: BlueprintMenuNpcEntry in _npcEntries:
		state[entry.npcID] = {
			"displayedName": entry.displayedName,
			"notes": entry.notes,
			"nameGuessedCorrectly": entry.nameGuessedCorrectly,
			"unlocked": entry.unlocked
		}
	return state

## [b]Internal-use only.[/b]  Restores the state of each NPC when window is reloaded.
func loadState(state:Dictionary) -> void:
	print("BlueprintWindow:  Loading data into entries.")
	for entry:BlueprintMenuNpcEntry in _npcEntries:
		if not state.has(entry.npcID):
			printerr("BlueprintWindow:  Skipping entry with ID of [", entry.npcID, "] due to given data not having any for it.")
			continue

		var entry_state: Dictionary = state[entry.npcID]
		entry.notes = str(entry_state.get("notes", ""))
		entry.nameGuessedCorrectly = bool(entry_state.get("nameGuessedCorrectly", false))

		var is_unlocked: bool = bool(entry_state.get("unlocked", false))
		if is_unlocked:
			entry.unlock()
		else:
			entry.lock()
			entry.displayedName = str(entry_state.get("displayedName", entry.lockedText))

## Closes this window and [member _detailWindow].
func close() -> void:
	if _detailWindow != null:
		_detailWindow.close()
		_detailWindow = null
	super()

## Removes this from the scene.
## If you want to close this window, run [method close] instead.
func kill() -> void:
	super()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Stores the [BlueprintMenuNpcEntry]s in [member _npcEntryHolder] to [member _npcEntries].
## Essentially only runs once due to being called in [method _ready].
func _loadEntries() -> void:
	if not _npcEntries.is_empty():
		printerr("BlueprintWindow:  Cannot load data into _npcEntryHolder due to it already having data.")
		return

	var index:int = 0
	for entry in _npcEntryHolder.get_children():
		if entry is not BlueprintMenuNpcEntry:
			continue
		entry = entry as BlueprintMenuNpcEntry

		# just in case
		if not entry.selected.is_connected(_on_npc_entry_selected):
			printerr("BlueprintWindow:  Signal \"selected\" not connected to this node's \"_on_npc_entry_selected\" function in-editor.  Please consider doing so.")
			entry.selected.connect(_on_npc_entry_selected)

		_npcEntries.push_back(entry)
		_idToIndex[entry.npcID] = index
		index += 1

## [b]Internal-use only.[/b]
## Gets the [member _npcEntries] index of a [BlueprintMenuNpcEntry].
## Returns [code]null[/code] if it cannot find an [BlueprintMenuNpcEntry] with the given [code]entryID[/code].
func _getEntry(entryID:String) -> BlueprintMenuNpcEntry:
	if not _idToIndex.has(entryID):
		printerr("BlueprintWindow:  Could not find entry with ID: [", entryID, "]")
		return null
	return _npcEntries[_idToIndex[entryID]]

## [b]Internal-use only.[/b]
## Shows details related to [_selectedEntry] by loading them into [member _detailWindow].
func _showDetails() -> void:
	if _selectedEntry == null:
		printerr("BlueprintWindow:  Cannot load details when no entry is selected.")
		return

	_detailWindow = FR_WindowManager.createBlueprintNpcDetailWindow()
	_detailWindow.loadEntry(_selectedEntry)

	if not _detailWindow.npc_name_submitted.is_connected(_on_detail_window_name_submitted):
		_detailWindow.npc_name_submitted.connect(_on_detail_window_name_submitted)
	else:
		printerr("BlueprintWindow:  How? (1)")
	if not _detailWindow.notes_changed.is_connected(_on_detail_window_notes_changed):
		_detailWindow.notes_changed.connect(_on_detail_window_notes_changed)
	else:
		printerr("BlueprintWindow:  How? (2)")

## [b]Internal-use only.[/b]
## Closes [memmber _detailWindow].
func _hideDetails() -> void:
	if _detailWindow != null:
		print("BlueprintWindow:  Closing details window.")
		_detailWindow.close()
		_detailWindow = null

## [b]Internal-use only.[/b]
## Determines if a given guess matches the name of the selected NPC entry.
func _determineIfGuessMatchesSelectedEntry(guess:String) -> void:
	var correctName:String = _selectedEntry.displayName
	if guess.to_lower() == correctName.to_lower():
		print("BlueprintWindow:  Correct name correctGuesses for ", _selectedEntry.npcID)
		_selectedEntry.nameGuessedCorrectly = true
		_playSfxSafe("entryGuessedCorrectly")
		npc_name_guessed_correctly.emit(_selectedEntry.npcID)
	else:
		print("BlueprintWindow:  Incorrect name for ", _selectedEntry.npcID)
		_selectedEntry.nameGuessedCorrectly = false
		_playSfxSafe("entryNameSubmitted")

## [b]Internal-use only.[/b]
## "Unlocks" all NPC entries whose names were guessed correctly.
func _unlockCorrectGuesses() -> void:
	print("BlueprintWindow:  Unlocking all correctly guessed entries.")
	var correctGuesses:Array[BlueprintMenuNpcEntry] = []
	for entry:BlueprintMenuNpcEntry in _npcEntries:
		if entry.nameGuessedCorrectly:
			correctGuesses.append(entry)

	if correctGuesses.size() >= numNeededBeforeUnlocking:
		for entry in correctGuesses:
			entry.unlock()

## [b]Internal-use only.[/b]
## Checks whether the defined unlock conditions have been met.
func _checkUnlockConditions() -> void:
	# the follow is an example unlock condition that checks if the player
	# has guessed the names of entries with IDs of "npc_test_1" and "npc_test_3"
	# correctly.
	var checker1 = _getEntry("npc_test_1")
	if not checker1:
		return

	var checker2 = _getEntry("npc_test_3")
	if not checker2:
		return

	if checker1.nameGuessedCorrectly and checker2.nameGuessedCorrectly:
		print("BlueprintWindow:  Door_A unlock condition met.")
		unlock_condition_met.emit("Door_A")

## [b]Internal-use only.[/b]
## Updates the visibility of each [member _npcEntries] [BlueprintMenuNpcEntry] child
## based on if they fit onto the current page.
func _updateEntryVisibility() -> void:
	if not _npcEntryHolder:
		return

	print("BlueprintWindow:  Updating visibility of entries.")
	var start_index = currentPageNum * npcEntriesPerPage
	var end_index = start_index + npcEntriesPerPage

	var i:int = 0
	for child in _npcEntryHolder.get_children():
		if child is not BlueprintMenuNpcEntry:
			continue
		child.visible = i >= start_index and i < end_index
		i += 1

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when a guess for the name is submitted
func _on_detail_window_name_submitted(entry:BlueprintMenuNpcEntry, submittedName: String) -> void:
	_selectedEntry = entry
	_selectedEntry.displayedName = submittedName

	_determineIfGuessMatchesSelectedEntry(submittedName)
	_unlockCorrectGuesses()
	_checkUnlockConditions()

	if _detailWindow != null:
		_detailWindow.loadEntry(_selectedEntry)

## [b]Internal-use only.[/b]
## Handles logic for when notes are typed.
func _on_detail_window_notes_changed(entry:BlueprintMenuNpcEntry, notes: String) -> void:
	entry.notes = notes

## [b]Internal-use only.[/b]
## Handles logic for when an [BlueprintMenuNpcEntry] is clicked.
func _on_npc_entry_selected(entry:BlueprintMenuNpcEntry) -> void:
	print("BlueprintWindow:  Entry with ID [", entry.npcID, "] was selected.")
	_playSfxSafe("buttonPressed")
	_selectedEntry = entry
	_showDetails()

## [b]Internal-use only.[/b]
## Handles logic for when the previous page button is pressed.
func _on_prev_page_button_pressed() -> void:
	if currentPageNum > 0:
		_playSfxSafe("buttonPressed")
		currentPageNum -= 1
		print("BlueprintWindow:  Decrementing to page #", currentPageNum, ".")
		_updateEntryVisibility()

## [b]Internal-use only.[/b]
## Handles logic for whene the next page button is pressed.
func _on_next_page_button_pressed() -> void:
	var max_page = int(ceil(float(_npcEntries.size()) / npcEntriesPerPage)) - 1
	if currentPageNum < max_page:
		_playSfxSafe("buttonPressed")
		currentPageNum += 1
		print("BlueprintWindow:  Incrementing to page #", currentPageNum, ".")
		_updateEntryVisibility()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	warnings.append_array(super())
	return warnings

func _validate_property(property: Dictionary) -> void:
	super(property)
