@tool
extends DialogueWindow
class_name BlueprintNpcDetailWindow
## Shows the details associated with a [BlueprintMenuNpcEntry].
##
## [b]Styling[/b][br]
## Be sure to look at the sstyling notes described in [DialogueWindow].
## [br][br]
## [b]SFX events[/b][br]
## Comes with the following optional SFX events, as well as the ones from [DialogueWindow]:[br]
## - buttonPressed:  plays when a button is presssed.[br]
## - guessNpcNameTextChanged:  plays when the text in [member _guessNpcNameField] gets updated.[br]
## - notesFieldTextUpdated:  plays when the text in [member _notesField] gets updated.[br]

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when a when a guess is submitted for an NPC name.
## [br][br]
## [code]entry[/code] is the entry that was selected when this window was opened.[br]
## [code]submittedName[/code] is the name that was submitted in [member _guessNpcNameField].
signal npc_name_submitted(entry:BlueprintMenuNpcEntry, submittedName:String)
## Emitted when notes are updated.
## [br][br]
## [code]entry[/code] is the entry that was selected when this window was opened.[br]
## [code]notes[/code] is the text contained within [member _notesField].
signal notes_changed(entry:BlueprintMenuNpcEntry, notes:String)

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
## [b]Internal-use only.[/b
## The node holding nodes related to guessing an entry's name.
@onready var _guessNpcNamePanel = %GuessNpcNamePanel
## [b]Internal-use only.[/b]
## The node where players enter their guess for an entry's name.
@onready var _guessNpcNameField: LineEdit = %GuessNpcNameField
## [b]Internal-use only.[/b]
## The node where players enter notes for an entry.
@onready var _notesField: TextEdit = %NotesField
## [b]Internal-use only.[/b]
## The node that displays an entry's portrait.
@onready var _portraitTextureRect: TextureRect = %Portrait

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## [b]Internal-use only.[/b]
## The entry that was selected when this window was opened.
var selectedEntry:BlueprintMenuNpcEntry = null

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Tracks whether notes are being loaded at this moment.
var _loadingNotes:bool = false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	windowType = "blueprint_detail"

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Loads the entry's data into the relevent areas.  Will hide the portrait if
## the given entry's portrait texture is [code]null[/code].
func loadEntry(entry:BlueprintMenuNpcEntry) -> void:
	if entry == null:
		printerr("BlueprintNpcDetailWindow:  Cannot load a null entry.")
		return
	print("BlueprintNpcDetailWindow:  Loading entry [", entry.npcID, "]'s data.")

	selectedEntry = entry
	headerText = entry.displayedName
	_guessNpcNamePanel.visible = not entry.unlocked

	_loadingNotes = true
	_notesField.text = selectedEntry.notes
	_loadingNotes = false

	if entry.portraitTexture == null:
		_portraitTextureRect.visible = false
		printerr("BlueprintNpcDetailWindow:  Entry with ID [", entry.npcID, "]'s portrait is not set.")
		return
	_portraitTextureRect.texture = entry.portraitTexture
	_portraitTextureRect.visible = true

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when a guess for the entry's name is submitted.
func _on_npc_entry_name_submission() -> void:
	if selectedEntry == null or selectedEntry.unlocked:
		return

	var submittedName: String = _guessNpcNameField.text.strip_edges()
	_guessNpcNameField.text = ""

	if submittedName == "":
		return
	npc_name_submitted.emit(selectedEntry, submittedName)

## [b]Internal-use only.[/b]
## Handles logic for when the text in [member _notesField] gets updated.
func _on_notes_field_text_changed() -> void:
	if _loadingNotes or selectedEntry == null:
		return

	selectedEntry.notes = _notesField.text
	notes_changed.emit(selectedEntry, _notesField.text)
	_playSfxSafe("notesFieldTextUpdated")

## [b]Internal-use only.[/b]
## Handles logic for when the text in [member _guessNpcNamePanel] gets updated.
func _on_guess_npc_name_field_text_changed(_new_text: String) -> void:
	_playSfxSafe("guessNpcNameTextChanged")
