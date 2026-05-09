@tool
extends Control
class_name BlueprintMenuNpcEntry
## A clickable NPC entry in the [BlueprintMenu].

# ------------------------------------------------
# signals
# ------------------------------------------------
signal selected(me:BlueprintMenuNpcEntry)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The ID of the NPC in this NPC entry.
@export var npcID:String = "npc_test"
## The name of the NPC in this entry/
@export var displayName:String = "NPC Test"
## The text that is displayed when this entry is locked.
@export var lockedText: String = "???"
## The icon for this entry when it is unlocked.  Setting this will update the button node.
@export var entryTextureUnlocked:Texture2D
## The icon for this entry when it is unlocked.  Setting this will update the button node.
@export var entryTextureLocked:Texture2D:
	set(newTexture):
		entryTextureLocked = newTexture
		if not Engine.is_editor_hint():  await ready
		_button.texture_normal = newTexture
## The image that appears in the details panel.
@export var portraitTexture: Texture2D

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The label node for this entry.
@onready var _label = %Label
## [b]Internal-use only.[/b]  The icon node for this entry.
@onready var _button = %TextureButton

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The name displayed for this NPC entry.
var displayedName:String:
	set(newName):
		_label.text = newName
	get():
		return _label.text
## The notes the player has written for this NPC entry.
var notes:String
## Whether the player has guessed the name of the NPC in this entry correctly or not.
var nameGuessedCorrectly:bool = false
## Whether this NPC entry is unlocked or not.
var unlocked:bool = false

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	lock()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Locks this NPC entry.
func lock() -> void:
	displayedName = lockedText
	_button.texture_normal = entryTextureLocked
	unlocked = false

## Updates thiss NPC entry label with whatever you put into in the function.
func updateLabel(newText: String) -> void:
	displayedName = newText

## Unlocks this NPC entry.
func unlock() -> void:
	displayedName = "✓ " + displayName
	_button.texture_normal = entryTextureUnlocked
	unlocked = true

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when this NPC entry is clicked.
func _on_pressed() -> void:
	selected.emit(self)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
