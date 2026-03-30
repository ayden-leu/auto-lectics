@tool
extends Node3D
class_name DialogueOption

## Emitted when this dialogue option is picked.
signal option_picked(option:DialogueOption, nextID:String)

## Used for referencing how the dialogue option should grow horizontally.
enum HORIZONTAL_ALIGNMENT{
	left,
	center,
	right
}
## Used for referencing how the dialogue option should grow vertically.
enum VERTICAL_ALIGNMENT{
	top,
	center,
	bottom
}

## The thickness of the background for the dialogue option.
@export var thickness:float = 0.08
## How much padding the text label of the dialogue option should have.
@export var labelPadding:Vector2 = Vector2(0.1, 0.1)
## How the dialogue option should grow horizontally.
@export var horizontalAlignment:HORIZONTAL_ALIGNMENT = HORIZONTAL_ALIGNMENT.right
## How the dialogue option should grow vertically.
@export var verticalAlignment:VERTICAL_ALIGNMENT = VERTICAL_ALIGNMENT.top

## Holds a reference to the text label that displays the dialogue option text.
@onready var label:Label3D = $TextLabel
## Holds the text that displays the current dialogue option. Mainly just used as an easier way to get/set the label text.
var text:String = "":
	set(value):
		text = value
		label.text = value
## Holds a reference to the interaction hitbox.
@onready var interactionHitbox:CollisionShape3D = $InteractionHitbox/CollisionShape3D
## Holds a reference to the background of the dialogue option.
@onready var background:MeshInstance3D = $Background
## Holds a reference to the lifetime timer that activates if this dialogue option has a lifetime.
@onready var lifeTimer:Timer = $LifeTimer
## Holds the AudioStreamPlayer3Ds for each event.
@onready var sfxPlayer:Dictionary[String, AudioStreamPlayer] = {
	"spawn": $SFX/spawn,
	"text": $SFX/text
}

## Padding amount for the interaction hitbox.
const interactionHitboxPadding:float = 0.05

## Used by DialogueBox for positioning dialogue options.
var labelHeight:float = 0.0  # used externally
## Mainly used in case the dialogue option dies in between an await call.
var goingToDie:bool = false
## How long it takes for a dialogue option to appear.
var spawnDelay:float = 0.0
## How long a dialogue option will last.
var lifetime:float = 0.0
## The ID of the next dialogue object to load.
var nextDialogueID:String
## The SFX sound events to load sound files into.
var sfxEventsToLoad:Dictionary
## Make it possible for dialogue to change a flag.
var setFlags: Dictionary = {}

func _ready() -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	visible = false
	
func _process(_delta: float) -> void:
	# Only runs this code while the game is running
	if Engine.is_editor_hint():
		applySettings()

## Runs any configurations that need to be run before continuing onward.
func prepare() -> void:
	await get_tree().create_timer(0.0001).timeout
	if goingToDie:
		return
	
	applySettings()
	visible = true
	interactionHitbox.disabled = false
	if lifetime > 0:
		lifeTimer.wait_time = lifetime
		lifeTimer.start()
	
	sfxPlayer.spawn.play()

## Loads the SFX from the files.
func loadSfx() -> void:
	for eventID in sfxPlayer.keys():
		AudioLoader.clearAudioFiles(sfxPlayer[eventID].stream)
		AudioLoader.loadAudioFiles(sfxEventsToLoad[eventID], sfxPlayer[eventID].stream)

## Applies all configured dialogue option settings.
func applySettings() -> void:
	if not Engine.is_editor_hint():
		loadSfx()
	
	applyLabelSettings()
	applyBackgroundSettings()

## Applies the horizontal and vertical alignment settings of the label.
func applyLabelSettings() -> void:    
	match horizontalAlignment:
		HORIZONTAL_ALIGNMENT.left:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			label.position.z = -labelPadding.x/2
		HORIZONTAL_ALIGNMENT.right:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			label.position.z = labelPadding.x/2
		HORIZONTAL_ALIGNMENT.center:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.position.z = 0
		_:
			printerr("DialogueOption: Unhandled horizontal alignment for label: ", horizontalAlignment)
	
	match verticalAlignment:
		VERTICAL_ALIGNMENT.top:
			label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			label.position.y = -labelPadding.y/2
		VERTICAL_ALIGNMENT.bottom:
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			label.position.y = labelPadding.y/2
		VERTICAL_ALIGNMENT.center:
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.position.y = 0
		_:
			printerr("DialogueOption: Unhandled vertical alignment for label: ", verticalAlignment)

## Applies the horizontal and vertical alignment settings of the background.
func applyBackgroundSettings() -> void:
	var labelSize:Vector3 = label.get_aabb().size
	
	background.mesh.size.x = thickness
	background.mesh.size.y = labelSize.y + labelPadding.y
	background.mesh.size.z = labelSize.x + labelPadding.x
	
	match horizontalAlignment:
		HORIZONTAL_ALIGNMENT.left:
			background.position.z = -labelSize.x/2 + label.position.z
		HORIZONTAL_ALIGNMENT.right:
			background.position.z = labelSize.x/2 + label.position.z
		HORIZONTAL_ALIGNMENT.center:
			background.position.z = 0
		_:
			printerr("DialogueOption: Unhandled horizontal alignment for background: ", horizontalAlignment)
	
	match verticalAlignment:
		VERTICAL_ALIGNMENT.top:
			#background.mesh.size.y = labelSize.y - label.position.y * 2
			background.position.y = -labelSize.y/2 + label.position.y
		VERTICAL_ALIGNMENT.bottom:
			#background.mesh.size.y = labelSize.y + label.position.y * 2
			background.position.y = labelSize.y/2 + label.position.y
		VERTICAL_ALIGNMENT.center:
			background.position.y = 0
		_:
			printerr("DialogueOption: Unhandled vertical alignment for background: ", verticalAlignment)

	interactionHitbox.shape.size = background.mesh.size + Vector3.ONE * interactionHitboxPadding
	interactionHitbox.position.y = background.position.y
	interactionHitbox.position.z = background.position.z
	
	labelHeight = interactionHitbox.shape.size.y

## Kills the dialogue option.
func kill():
	goingToDie = true
	for eventID in sfxPlayer.keys():
		AudioLoader.clearAudioFiles(sfxPlayer[eventID].stream)
	queue_free()



## Handles logic for when the dialogue option gets picked.
func _on_interaction(_interactor:Node3D) -> void:
	visible = false
	interactionHitbox.disabled = true
	lifeTimer.stop()
	sfxPlayer.spawn.stop()
	option_picked.emit(self, nextDialogueID)

## Handles the logic for when the lifetime of the dialogue option expires.
func _on_life_timer_timeout() -> void:
	kill()
