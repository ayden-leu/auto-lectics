@tool
extends DialogueWindow
class_name BlueprintNpcDetailWindow

# ------------------------------------------------
# signals
# ------------------------------------------------
## [b]Internal-use only.[/b] Signal sent when a guess is submitted for an NPC name
signal npc_name_submitted(entry: BlueprintMenuNpcEntry, submitted_name: String)
## [b]Internal-use only.[/b] Signal sent when notes are updated
signal notes_changed(entry: BlueprintMenuNpcEntry, notes: String)
# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b] Stores a reference to the Panel containing name stuff
@onready var _guessNpcNamePanel = %GuessNpcNamePanel
## [b]Internal-use only.[/b] Stores reference to the line where you type the name
@onready var _guessNpcNameField: LineEdit = %GuessNpcNameField
## [b]Internal-use only.[/b] Stores reference to the submit guess button
@onready var _notesField: TextEdit = %NotesField
## [b]Internal-use only.[/b] Stores a reference to the portrait of the NPC
@onready var _portraitTextureRect: TextureRect = %Portrait

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## [b]Internal-use only.[/b] Stores the NPC in question
var selectedEntry: BlueprintMenuNpcEntry = null

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b] Tracks whether notes are being loaded
var _loadingNotes: bool = false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	windowType = "blueprint_detail"
	process_mode = Node.PROCESS_MODE_ALWAYS

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b] Loads the entry's data into the window
func load_entry(entry: BlueprintMenuNpcEntry) -> void:
	selectedEntry = entry
	if selectedEntry == null:
		return
	
	print("Loading detail entry: ", selectedEntry.npcID)
	print("Portrait texture: ", selectedEntry.portraitTexture)
	
	headerText = selectedEntry.displayedName
	_guessNpcNamePanel.visible = not selectedEntry.unlocked
	
	if _portraitTextureRect == null:
		printerr("BlueprintNpcDetailWindow: _portraitTextureRect is null.")
		return
	
	_portraitTextureRect.texture = selectedEntry.portraitTexture
	_portraitTextureRect.visible = selectedEntry.portraitTexture != null
	
	_loadingNotes = true
	_notesField.text = selectedEntry.notes
	_loadingNotes = false

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b] Handles logic for when a guess for the name is submitted
func _on_npc_entry_name_submission() -> void:
	if selectedEntry == null:
		return
	if selectedEntry.unlocked:
		return
	
	var submittedName: String = _guessNpcNameField.text.strip_edges()
	_guessNpcNameField.text = ""
	
	if submittedName == "":
		return
	npc_name_submitted.emit(selectedEntry, submittedName)

## [b]Internal-use only.[/b] handles logic for when notes are updated
func _on_notes_field_text_changed() -> void:
	if _loadingNotes:
		return
	if selectedEntry == null:
		return
	selectedEntry.notes = _notesField.text
	notes_changed.emit(selectedEntry, _notesField.text)

## [b]Internal-use only.[/b] Handles logic for when name entry line is typed in
func _on_guess_npc_name_field_text_changed(_new_text: String) -> void:
	if sfxEventHandler:
		sfxEventHandler.play("guessNpcNameTextChanged")
