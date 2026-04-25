@tool
extends Control
class_name BlueprintMenuNpcEntry
## A clickable NPC entry in the [BlueprintMenu].

# ------------------------------------------------
# signals
# ------------------------------------------------
signal selected(id: String)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The ID of this NPC entry.
@export var id: String = "npc_test"
## The text that is displayed when this entry is locked.
@export var lockedText: String = "???"
## The icon for this entry.  Setting this will update the icon node.
@export var entryTexture:Texture2D:
	set(newTexture):
		entryTexture = newTexture
		await self.ready
		_icon.texture = newTexture

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The label node for this entry.
@onready var _label = %Label
## [b]Internal-use only.[/b]  The icon node for this entry.
@onready var _icon = %Icon

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

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
	_label.text = lockedText

## Updates thiss NPC entry label with whatever you put into in the function.
func updateLabel(newText: String) -> void:
	_label.text = newText

## Unlocks this NPC entry.
func unlock(newText: String) -> void:
	updateLabel("✓ " + newText)

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when this NPC entry is clicked.
func _on_pressed() -> void:
	selected.emit(id)
	
# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
