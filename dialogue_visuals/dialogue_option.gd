@tool
extends Node3D
class_name DialogueBoxOption
## @deprecated
## [b]Internal-use only.[/b]  A dialogue option that spawns when a user is able to
## continue a dialogue event.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this dialogue option is picked.
signal option_picked(option:DialogueBoxOption, nextID:String)

# ------------------------------------------------
# enums
# ------------------------------------------------
## Used for referencing how the dialogue option should grow horizontally.
enum HorizAlignment{ # not named HorizontalAlignment due to it already existing
	LEFT,
	CENTER,
	RIGHT
}
## Used for referencing how the dialogue option should grow vertically.
enum VertiAlignment{ # not named HorizontalAlignment due to it already existing
	TOP,
	CENTER,
	BOTTOM
}

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]  Padding amount for the interaction hitbox.
const _INTERACTION_HITBOX_PADDING:float = 0.05

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The thickness of the _background for the dialogue option.
@export var thickness:float = 0.08
## How much padding the text label of the dialogue option should have.
@export var labelPadding:Vector2 = Vector2(0.1, 0.1)
## How the dialogue option should grow horizontally.
@export var horizontalAlignment:HorizAlignment = HorizAlignment.RIGHT
## How the dialogue option should grow vertically.
@export var verticalAlignment:VertiAlignment = VertiAlignment.TOP

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  Holds a reference to the text label that displays the dialogue option text.
@onready var _label:Label3D = $TextLabel
## [b]Internal-use only.[/b]  Holds a reference to the interaction hitbox.
@onready var _interactionHitbox:CollisionShape3D = $InteractionHitbox/CollisionShape3D
## [b]Internal-use only.[/b]  Holds a reference to the _background of the dialogue option.
@onready var _background:MeshInstance3D = $Background
## [b]Internal-use only.[/b]  Holds a reference to the lifetime timer that activates if this dialogue option has a lifetime.
@onready var _lifeTimer:Timer = $LifeTimer
## [b]Internal-use only.[/b]  Holds the AudioStreamPlayer3Ds for each event.
@onready var _sfxPlayer:Dictionary[String, AudioStreamPlayer3D] = {
	"spawn": %SFX/spawn,
	"text": %SFX/text
}

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Holds the text that displays the current dialogue option. Mainly just used as an easier way to get/set the label text.
var text:String = "":
	set(value):
		text = value
		_label.text = value
## Used by DialogueBox for positioning dialogue options.
var labelHeight:float = 0.0  # used externally
## How long a dialogue option will last.
var lifetime:float = 0.0
## The ID of the next dialogue object to load.
var nextDialogueID:String
## The SFX sound events to load sound files into.
var sfxEventsToLoad:Dictionary
## The [member StoryFlags.default_flags] this updates when picked.
var setFlags: Dictionary = {}

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Mainly used in case the dialogue option dies in between an await call.
var _goingToDie:bool = false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	visible = false
	
func _process(_delta: float) -> void:
	# Only runs this code while the game is running
	if Engine.is_editor_hint():
		_applySettings()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Runs any configurations that need to be run before continuing onward.
func prepare() -> void:
	await get_tree().create_timer(0.0001).timeout
	if _goingToDie:
		return
	
	_applySettings()
	visible = true
	_interactionHitbox.disabled = false
	if lifetime > 0:
		_lifeTimer.wait_time = lifetime
		_lifeTimer.start()
	
	_sfxPlayer.spawn.play()

## Loads the SFX from the files.
func loadSfx() -> void:
	for eventID in _sfxPlayer.keys():
		AudioLoader.clearAudioFiles(_sfxPlayer[eventID].stream)
		AudioLoader.loadAudioFiles(sfxEventsToLoad[eventID], _sfxPlayer[eventID].stream)

## Disables this option.
func disable() -> void:
	visible = false
	_interactionHitbox.disabled = true
	_lifeTimer.stop()
	_sfxPlayer.spawn.stop()

## Kills the dialogue option.
func kill():
	_goingToDie = true
	for eventID in _sfxPlayer.keys():
		AudioLoader.clearAudioFiles(_sfxPlayer[eventID].stream)
	queue_free()
# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Applies all configured dialogue option settings.
func _applySettings() -> void:
	if not Engine.is_editor_hint():
		loadSfx()
	
	_applyLabelSettings()
	_applyBackgroundSettings()

## [b]Internal-use only.[/b]  Applies the horizontal and vertical alignment settings of the label.
func _applyLabelSettings() -> void:    
	match horizontalAlignment:
		HorizAlignment.LEFT:
			_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
			_label.position.z = -labelPadding.x/2
		HorizAlignment.RIGHT:
			_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
			_label.position.z = labelPadding.x/2
		HorizAlignment.CENTER:
			_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
			_label.position.z = 0
		_:
			printerr("DialogueBoxOption: Unhandled horizontal alignment for label: ", horizontalAlignment)
	
	match verticalAlignment:
		VertiAlignment.TOP:
			_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			_label.position.y = -labelPadding.y/2
		VertiAlignment.BOTTOM:
			_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			_label.position.y = labelPadding.y/2
		VertiAlignment.CENTER:
			_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			_label.position.y = 0
		_:
			printerr("DialogueBoxOption: Unhandled vertical alignment for label: ", verticalAlignment)

## [b]Internal-use only.[/b]  Applies the horizontal and vertical alignment settings of the _background.
func _applyBackgroundSettings() -> void:
	var labelSize:Vector3 = _label.get_aabb().size
	
	_background.mesh.size.x = thickness
	_background.mesh.size.y = labelSize.y + labelPadding.y
	_background.mesh.size.z = labelSize.x + labelPadding.x
	
	match horizontalAlignment:
		HorizAlignment.LEFT:
			_background.position.z = -labelSize.x/2 + _label.position.z
		HorizAlignment.RIGHT:
			_background.position.z = labelSize.x/2 + _label.position.z
		HorizAlignment.CENTER:
			_background.position.z = 0
		_:
			printerr("DialogueBoxOption: Unhandled horizontal alignment for _background: ", horizontalAlignment)
	
	match verticalAlignment:
		VertiAlignment.TOP:
			#_background.mesh.size.y = labelSize.y - label.position.y * 2
			_background.position.y = -labelSize.y/2 + _label.position.y
		VertiAlignment.BOTTOM:
			#_background.mesh.size.y = labelSize.y + label.position.y * 2
			_background.position.y = labelSize.y/2 + _label.position.y
		VertiAlignment.CENTER:
			_background.position.y = 0
		_:
			printerr("DialogueBoxOption: Unhandled vertical alignment for _background: ", verticalAlignment)

	_interactionHitbox.shape.size = _background.mesh.size + Vector3.ONE * _INTERACTION_HITBOX_PADDING
	_interactionHitbox.position.y = _background.position.y
	_interactionHitbox.position.z = _background.position.z
	
	labelHeight = _interactionHitbox.shape.size.y

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when the dialogue option gets picked.
func _on_interaction(_interactor:Node3D) -> void:
	disable()
	option_picked.emit(self, nextDialogueID)

## [b]Internal-use only.[/b]  Handles the logic for when the lifetime of the dialogue option expires.
func _on_life_timer_timeout() -> void:
	kill()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
