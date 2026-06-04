@tool
@icon("uid://b0xrrnjriup2r")
extends AudioStreamPlayer
class_name VocalDialoguePlayerOperative
## Plays audio files in a vocal dialogue tree and displays subtitles.
##
## Vocal dialogue files that can be loaded by this are located in subfolders
## located in [member STORAGE_PATH] and are of type [member DIALOGUE_FILE_EXTENSION].
## The name of a subfolder corresponds to the dialogue tree ID.
## The names of each audio file do not matter, however their file extension/type
## should be of type [member AUDIO_FILE_EXTENSION].
## [codeblock lang=text]
## STORAGE_PATH
## ├── tree_id_1
## │   ├── DEFAULTS_FILE_NAME.DIALOGUE_FILE_EXTENSION
## │   ├── node_id_1.DIALOGUE_FILE_EXTENSION
## │   ├── node_id_2.DIALOGUE_FILE_EXTENSION
## │   └── node_id_3.DIALOGUE_FILE_EXTENSION
## ├── tree_id_2
## │   ├── DEFAULTS_FILE_NAME.DIALOGUE_FILE_EXTENSION
## │   └── node_id_1.DIALOGUE_FILE_EXTENSION
## └── tree_id_3
##     ├── DEFAULTS_FILE_NAME.DIALOGUE_FILE_EXTENSION
##     └── node_id_1.DIALOGUE_FILE_EXTENSION
## [/codeblock]
## [br]
## The format of the file's content should be in JSON format, and it supports the following fields:
## [codeblock]
## {
## 	"file": "the name of the audio file, without the extension",
## 	"subtitles": "what is loaded into the subtitles",
## 	"delayBeforeAllowContinue": # how long to wait after the audio file is finished before continuing, in seconds.
## 	"nextID": "the file name/ID of the next vocal dialogue file to load"
## }
## [/codeblock]
## Every field will be given a fallback value if it is not found in the main vocal dialogue file,
## or the vocal dialogue tree's defaults, except for [code]"file"[/code].
## If the [code]"file"[/code] field is missing, the subtitles will be overwritten with an error message.
## [br][br]
## [b]Styling[/b][br]
## The continue icon can be found in [code]_framework/_visual_assets/vocal_dialogue_player/continue_icon.png[/code].
## You can overwrite it or replace [member contineIcon]'s texture with a different file.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the next vocal dialogue is loaded.
signal dialogue_advanced()
## Emitted when the vocal dialogue hits an end.
signal dialogue_finished()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## Where all of the vocal dialogue trees are stored.
const STORAGE_PATH:String = "res://dialogue_trees/vocal/"
## THe file extension of the audio file that is played.
const AUDIO_FILE_EXTENSION:String = ".mp3"
## THe file extension of the dialogue file node.
const DIALOGUE_FILE_EXTENSION:String = ".json"
## THe file name of the vocal dialogue defaults file.
const DEFAULTS_FILE_NAME:String = "_default"
## The fallback data to load in case something goes wrong.
const FALLBACK:Dictionary = {
	"subtitles": "there were no subtitles or there was an issue loading them",
	"delayBeforeAllowContinue": 0.0,
	"nextID": ""
}
## The error meessage when the audio file cannot be loaded.
const ERROR_MSG_CANT_LOAD_AUDIO:String = "an error has occured while loading the audio file"
## The error meessage when there is no audio file to be loaded when there should be.
const ERROR_MSG_AUDIO_TO_LOAD_NOT_SET:String = "an error has occured due to there being no defined audio file to load"

# ------------------------------------------------
# export variables
# ------------------------------------------------
## If this can do stuff or not.
@export var enabled:bool = true
## The name of the subfolder to look into located at [member STORAGE_PATH].
@export var dialogueTreeID:String:
	set(newID):
		dialogueTreeID = newID
		update_configuration_warnings()
## The vocal dialogue file to load at the start.
@export var initialDialogueID:String:
	set(newID):
		initialDialogueID = newID
		update_configuration_warnings()
## The delay, in seconds, between the audio file finishing playing, and being able to continue.
@export var delayBeforeAllowContinue:float = 0.0
## If the subtitles should fade out or not before the player is able to continue.
@export var fadeSubtitles:bool = false

## If this should start doing its thing from interaction or not.
@export var startFromInteraction:bool = false:
	set(newState):
		startFromInteraction = newState
		update_configuration_warnings()
		notify_property_list_changed()
@export_category("Interaction Stuff")
## If the player can only interact with this once, assuming [startFromInteraction] is [code]true[/code].
## When the player starts an interaction again, it will start from [member intialDialogueID] again.
@export var interactOnlyOnce:bool = false

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## The node that holds the subtitles text.
@onready var subtitles:Label = %Subtitles
## The node that holds the image to display when the player is able to continue the dialogue.
@onready var continueIcon:TextureRect = %ContinueIcon

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The current vocal dialogue file to load.
var currentDialogueID:String = ""
## If this is currently in the process of doing stuff or not.
var interactedWith:bool = false

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
# [b]Internal-use only.[/b]
## The next vocal dialogue file to load.
var _nextDialogueID: String = ""
## [b]Internal-use only.[/b]
## Whether the player can continue forward or not.
var _canContinue:bool = true
## [b]Editor-use only.[/b]
## The first [Area3D] child thiis node has, and only the first.
## Is obtained via [method _get_area].
var _hitbox:Area3D
## [b]Editor-use only.[/b]
## The previous collision layer state of [_hitbox], specifically for the 3rd (NPC) layer.
var _prevHitboxCollisionValue:bool

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
#	$Timer.start()
	if Engine.is_editor_hint():
		_hitbox = _get_area()
		if not _hitbox:
			return
		_prevHitboxCollisionValue = _hitbox.get_collision_layer_value(3)
		print(_hitbox,"hitbxo")
		return
	

	currentDialogueID = initialDialogueID
	subtitles.visible = false
	continueIcon.visible = false
	
	

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_hitbox = _get_area()
		# this is needed to detect when the collision layer gets updated
		if _hitbox and not _hitbox.get_collision_layer_value(3):
			update_configuration_warnings()
		return

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Loads the [member _nextDialogueID] vocal dialogue file and starts playing it.
func loadNextDialogue() -> void:
	if not enabled or not _canContinue:
		return
	_canContinue = false
	dialogue_advanced.emit()

	if currentDialogueID == "":
		call_deferred("_finish")
		return

	# actual file
	var file_path:String = STORAGE_PATH + dialogueTreeID + "/" + currentDialogueID + DIALOGUE_FILE_EXTENSION
	var dialogue_data:Dictionary = DialogueLoader.loadDialogueNodeFile(file_path)
	if dialogue_data.is_empty():
		printerr("VocalDialoguePlayer:  Loaded vocal dialogue file at [", file_path, " is empty or invalid.")

	var result:Error = _verifyDataFields(dialogue_data)
	if result == Error.ERR_INVALID_DATA:
		print("VocalDialoguePlayer:  Vocal dialogue file at [", file_path, "]'s field is the wrong data type.  Check above for which field.")

	# tree defaults
	dialogue_data = _loadTreeDefaults(dialogue_data)

	# fallback
	var base:Dictionary = FALLBACK.duplicate(true)
	if dialogue_data.has("file"):
		base.file = dialogue_data.file
	if dialogue_data.has("subtitles"):
		base.subtitles = dialogue_data.subtitles
	if dialogue_data.has("delayBeforeAllowContinue"):
		base.delayBeforeAllowContinue = dialogue_data.delayBeforeAllowContinue
	if dialogue_data.has("nextID"):
		base.nextID = dialogue_data.nextID

	_prepare(base)
	await _begin()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Verifies the contents of the vocal dialogue file data.
## Returns [member Error.ERR_INVALID_DATA] if the value of a field isn't the right type.
## Otherwise, returns [member Error.OK].
func _verifyDataFields(dialogue_data:Dictionary) -> Error:
	var fields:Dictionary[String, int] = {
		"file": TYPE_STRING,
		"subtitles": TYPE_STRING,
		"delayBeforeAllowContinue": TYPE_FLOAT,
		"nextID": TYPE_STRING
	}

	for field in fields:
		if not dialogue_data.has(field):
			printerr("VocalDialoguePlayer:  Vocal dialogue file is missing the [", field, "] field.")
			continue
		if not typeof(dialogue_data[field]) == fields[field]:
			printerr("VocalDialoguePlayer:  Field [", field, "] in dialogue data doesn't match expected type [", type_string(fields[field]), "].")
			return Error.ERR_INVALID_DATA
	return Error.OK

## [b]Internal-use only.[/b]
## Merges the dialogue tree's default values into the given dialogue data.
## Returns the result of that merge.
func _loadTreeDefaults(dialogueData:Dictionary) -> Dictionary:
	var filePath:String = STORAGE_PATH + dialogueTreeID + "/" + DEFAULTS_FILE_NAME + DIALOGUE_FILE_EXTENSION
	var defaultData:Dictionary = DialogueLoader.loadDialogueNodeFile(filePath)
	if defaultData.is_empty():
		print("VocalDialoguePlayer:  defaults dialogue file [", filePath, "] is either empty, doesn't exist, or an error occurred.  Will continue without loading defaults.")
		return dialogueData

	if not _verifyDataFields(defaultData):
		print("VocalDialoguePlayer:  defaults dialogue file at [", filePath, "] is invalid.  Check above for the potential reason.  Will continue without loading defaults.")
		return dialogueData

	if dialogueData.has("file"):
		defaultData.file = dialogueData.file
	if dialogueData.has("subtitles"):
		defaultData.subtitles = dialogueData.subtitles
	if dialogueData.has("delayBeforeAllowContinue"):
		defaultData.delayBeforeAllowContinue = dialogueData.delayBeforeAllowContinue
	if dialogueData.has("nextID"):
		defaultData.nextID = dialogueData.nextID

	return defaultData

## [b]Internal-use only.[/b]
## Prepares various internals based on the dialogue data given.
func _prepare(dialogue_data: Dictionary) -> void:
	_canContinue = false
	continueIcon.visible = false

	if dialogue_data.has("file"):
		var audio_file_name: String = dialogue_data.file
		var audio_path: String = STORAGE_PATH + dialogueTreeID + "/" + audio_file_name + AUDIO_FILE_EXTENSION

		var loaded_audio:AudioStream = load(audio_path)
		if loaded_audio == null:
			printerr("VocalDialoguePlayer:  Could not load vocal dialogue audio file at [", audio_path, "].")
			dialogue_data.subtitles = ERROR_MSG_CANT_LOAD_AUDIO
			fadeSubtitles = false
		stream = loaded_audio
	else:
		dialogue_data.subtitles = ERROR_MSG_AUDIO_TO_LOAD_NOT_SET

	subtitles.text = dialogue_data.subtitles
	delayBeforeAllowContinue = float(dialogue_data.delayBeforeAllowContinue)
	_nextDialogueID = dialogue_data.nextID

## [b]Internal-use only.[/b]
## Starts the vocal dialogue event.
func _begin() -> void:
	subtitles.visible = true
	subtitles.modulate.a = 1.0
	play()

	if stream != null:
		await finished

	if delayBeforeAllowContinue > 0.0:
		#await get_tree().create_timer(delayBeforeAllowContinue).finished
		var timer:SceneTreeTimer = get_tree().create_timer(delayBeforeAllowContinue)
		await timer.timeout

	if fadeSubtitles and subtitles.text != FALLBACK.subtitles:
		await _fadeOutSubtitles()

	continueIcon.visible = true
	_canContinue = true
	currentDialogueID = _nextDialogueID

## [b]Internal-use only.[/b]
## Fades the subtitles out to be invisible.
func _fadeOutSubtitles() -> void:
	var tween:Tween = create_tween()
	tween.tween_property(
		subtitles,
		"modulate:a",
		0.0,
		1.0
	)
	await tween.finished

	subtitles.visible = false

## [b]Internal-use only.[/b]
## Ends the vocal dialogue event.
func _finish() -> void:
	subtitles.visible = false
	continueIcon.visible = false
	if not interactOnlyOnce:
		_canContinue = true
		interactedWith = false
		currentDialogueID = initialDialogueID

	dialogue_finished.emit()
	

## [b]Internal-use only.[/b]
## Gets this node's first [Area3D] child, and only the first one.
func _get_area() -> Area3D:
	var children:Array = get_children()
	for child in children:
		if child is Area3D:
			return child
	return null
	

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when the player presses the interact button.
func _on_input_handler_interact_button_pressed() -> void:
	if startFromInteraction and not interactedWith:
		return

	loadNextDialogue()

## [b]Internal-use only.[/b]
## Handles logic for when this node's [Area3D] node gets interacted with.
func _on_interaction(interactor:Node3D) -> void:
	if not startFromInteraction and not interactedWith:
		return

	#_beginDialogueEventBox(interactor)
	if interactor is Player:
		interactedWith = true
		loadNextDialogue()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Editor-use Only.[/b]
## Returns editor warnings depending on this thing's state.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if self != get_tree().edited_scene_root:
		if not dialogueTreeID:
			warnings.push_back(
				"Dialogue tree ID not set."
			)
		if not initialDialogueID:
			warnings.push_back(
				"Initial dialogue ID not set."
			)

		if startFromInteraction:
			if _hitbox == null:
				warnings.push_back(
					"Needs an Area3D child so interaction can happen."
				)
			else:
				if not _hitbox.get_collision_layer_value(3):
					warnings.push_back(
						"Area3D child needs its third collision layer (named NPC) to be enabled so interaction can happen."
					)

	return warnings

## [b]Editor-use Only.[/b]
## Updates property visibility depending on this thing's state.
func _validate_property(property: Dictionary) -> void:
	if property.name in ["interactOnlyOnce"] and not startFromInteraction:
		property.usage = PROPERTY_USAGE_NO_EDITOR


func _on_timer_timeout() -> void:
	if startFromInteraction and not interactedWith:
		return

	loadNextDialogue()
	pass # Replace with function body.
