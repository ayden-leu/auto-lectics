@icon("uid://b0xrrnjriup2r")
extends AudioStreamPlayer
class_name VocalDialoguePlayer
## Plays audio files in a vocal dialogue tree and displays subtitles.
##
## This component will be helpful to use if you want to play spoken dialogue
## during the game.
## [br][br][br]
## [b]Using:[/b][br]
## Add the pre-built [VocalDialoguePlayer] scene to your current scene.
## You cannot add it through the "Create New Node" dialogue due to it acting differently.
## [br][br]
## You can then configure the export fields to to load your vocal dialogue tree.
## [br][br]
## [member dialogueTreeID] is the name of the subfolder that contains all of the
## vocal dialogue tree nodes for that vocal dialogue tree.
## [br][br]
## [member initialDialogueID] is the first vocal dialogue tree node that gets loaded.
## [br][br]
## [member delayBeforeAllowContinue] is the delay, in seconds, between the audio
## finishing and allowing the player to load the next vocal dialogue tree node.
## [br][br]
## If [member fadeSubtitles] is on, the subtitles will fade away after the audio
## file is finished playing.  This takes [code]1.0[/code] seconds and will add
## onto the delay that [member delayBeforeAllowContinue] provides.
## [br][br]
## There are also signals for various events that occur while this runs.  Refer
## to the signals section for a list of them.
## [br][br][br]
## [b]Formatting:[/b][br]
## Vocal dialogue files that can be loaded by this are located in subfolders
## located in [member STORAGE_PATH] and are of type [member DIALOGUE_FILE_EXTENSION].
## The name of a subfolder corresponds to the vocal dialogue tree ID.
## The names of each audio file do not matter, however their file extension/type
## should be of type [member AUDIO_FILE_EXTENSION].
## [codeblock lang=text]
## STORAGE_PATH
## ├── tree_id_1
## │   ├── DEFAULTS_FILE_NAME.DIALOGUE_FILE_EXTENSION
## │   ├── node_id_1.DIALOGUE_FILE_EXTENSION
## │   ├── node_1_audio_file.AUDIO_FILE_EXTENSION
## │   ├── node_id_2.DIALOGUE_FILE_EXTENSION
## │   ├── node_2_audio_file.AUDIO_FILE_EXTENSION
## │   ├── node_id_3.DIALOGUE_FILE_EXTENSION
## │   └── node_3_audio_file.AUDIO_FILE_EXTENSION
## ├── tree_id_2
## │   ├── DEFAULTS_FILE_NAME.DIALOGUE_FILE_EXTENSION
## │   ├── node_id_1.DIALOGUE_FILE_EXTENSION
## │   └── node_1_audio_file.AUDIO_FILE_EXTENSION
## └── tree_id_3
##     ├── DEFAULTS_FILE_NAME.DIALOGUE_FILE_EXTENSION
##     ├── node_id_1.DIALOGUE_FILE_EXTENSION
##     └── node_1_audio_file.AUDIO_FILE_EXTENSION
## [/codeblock]
## [br]
## The format of the file's content should be in JSON format, and it supports the following fields:
## [codeblock]
## {
## 	"file": "the name of the audio file, without the extension",
## 	"subtitles": "what is loaded into the subtitles",
## 	"delayBeforeAllowContinue": 0.0, # how long to wait after the
## 	# audio file is finished before continuing, in seconds.
## 	"nextID": "the file name/ID of the next vocal dialogue file to load"
## }
## [/codeblock]
## Every field will be given a fallback value if it is not found in the main vocal dialogue file,
## or the vocal dialogue tree's defaults, except for [code]"file"[/code].
## If the [code]"file"[/code] field is missing, the subtitles will be overwritten with an error message.
## [br][br][br]
## [b]Styling[/b][br]
## The continue icon can be found in [code]_framework/_visual_assets/vocal_dialogue_player/continue_icon.png[/code].
## You can overwrite it or replace [member contineIcon]'s texture with a different file.
## [br]
## It looks like this:  [img]res://_framework/_visual_assets/vocal_dialogue_player/continue_icon.png[/img]

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the next vocal dialogue node is loaded.
signal dialogue_advanced()
## Emitted when the vocal dialogue hits an end.
## (i.e when [member _nextDialogueID] is empty).
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
@export var dialogueTreeID:String
## The vocal dialogue file to load at the start.
@export var initialDialogueID:String
## The delay, in seconds, between the audio file finishing playing, and being able to continue.
@export var delayBeforeAllowContinue:float = 0.0
## If the subtitles should fade out or not before the player is able to continue.
## This takes [code]1.0[/code] seconds and will add onto the delay that
## [member delayBeforeAllowContinue] provides.
@export var fadeSubtitles:bool = false

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## The node that holds the subtitles text.
@onready var subtitles:Label = %Subtitles
## The node that holds the image to display when the player is able to continue the dialogue.
## [br]
## It looks like this:  [img]res://_framework/_visual_assets/vocal_dialogue_player/continue_icon.png[/img]
@onready var continueIcon:TextureRect = %ContinueIcon

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The current vocal dialogue file to load.
var currentDialogueID:String = ""

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## The next vocal dialogue file to load.
var _nextDialogueID: String = ""
## Whether the player can continue forward or not.
var _canContinue:bool = true

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	currentDialogueID = initialDialogueID
	subtitles.visible = false
	continueIcon.visible = false

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Loads the [member _nextDialogueID] vocal dialogue file and starts playing it.
## [br]
## It loads the data in a top-down fashion, with each layer replacing the fields
## of the layer below if they happen to overlap.
## [codeblock lang=text]
## Actual File
##   \/
## Vocal Dialogue Tree defaults
##   \/
## FALLBACK data
## [/codeblock]
## So if the defaults has a value for [member delayBeforeAllowContinue], but the
## actual file doesn't, the system will use the defaults' value.
func loadNextDialogue() -> void:
	if not enabled or not _canContinue:
		return
	_canContinue = false
	dialogue_advanced.emit()

	if currentDialogueID == "":
		_finish()
		return

	# actual file
	var file_path:String = STORAGE_PATH + dialogueTreeID + "/" + currentDialogueID + DIALOGUE_FILE_EXTENSION
	var dialogue_data:Dictionary = DialogueLoader.loadDialogueNodeFile(file_path)
	if dialogue_data.is_empty():
		DebugHud.addToLog("VocalDialoguePlayer:  Loaded vocal dialogue file at [" + file_path + " is empty or invalid.", DebugHud.LogType.ERROR)

	var result:Error = _verifyDataFields(dialogue_data)
	if result == Error.ERR_INVALID_DATA:
		DebugHud.addToLog("VocalDialoguePlayer:  Vocal dialogue file at [" + file_path + "]'s field is the wrong data type.  Check above for which field.", DebugHud.LogType.WARNING)

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
## [br][br]
## A valid vocal dialogue file has the following data types associated with the following keys.
## [codeblock]
## "file":  A string.
## "subtitles":  A string.
## "delayBeforeAllowContinue":  A float.
## "nextID":  A string.
## [/codeblock]
## [br]
## Returns [member Error.ERR_INVALID_DATA] if the value of a field isn't the right type.
## Otherwise, returns [member Error.OK].
func _verifyDataFields(dialogue_data:Dictionary) -> Error:
	var fields:Dictionary[String, int] = {
		"file": TYPE_STRING,
		"subtitles": TYPE_STRING,
		"delayBeforeAllowContinue": TYPE_FLOAT,
		"nextID": TYPE_STRING
	}

	for field:String in fields:
		if not dialogue_data.has(field):
			DebugHud.addToLog("VocalDialoguePlayer:  Vocal dialogue file is missing the [" + field + "] field.", DebugHud.LogType.WARNING)
			continue
		elif not typeof(dialogue_data[field]) == fields[field]:
			DebugHud.addToLog("VocalDialoguePlayer:  Field [" + field + "] in dialogue data doesn't match expected type [" + type_string(fields[field]) + "].", DebugHud.LogType.ERROR)
			return Error.ERR_INVALID_DATA
	return Error.OK

## [b]Internal-use only.[/b]
## Merges the given dialogue data into the dialogue tree's default values.
## Returns the result of that merge.
func _loadTreeDefaults(dialogueData:Dictionary) -> Dictionary:
	var filePath:String = STORAGE_PATH + dialogueTreeID + "/" + DEFAULTS_FILE_NAME + DIALOGUE_FILE_EXTENSION
	var defaultData:Dictionary = DialogueLoader.loadDialogueNodeFile(filePath)
	if defaultData.is_empty():
		DebugHud.addToLog("VocalDialoguePlayer:  Defaults dialogue file [" + filePath + "] is either empty, doesn't exist, or an error occurred.  Will continue without loading defaults.", DebugHud.LogType.WARNING)
		return dialogueData

	if not _verifyDataFields(defaultData):
		DebugHud.addToLog("VocalDialoguePlayer:  Defaults dialogue file at [" + filePath + "] is invalid.  Check above for the potential reason.  Will continue without loading defaults.", DebugHud.LogType.WARNING)
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
			DebugHud.addToLog("VocalDialoguePlayer:  Could not load vocal dialogue audio file at [" + audio_path + "].", DebugHud.LogType.WARNING)
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
		1.0  # the duration of the fade out
	)
	await tween.finished

	subtitles.visible = false

## [b]Internal-use only.[/b]
## Ends the vocal dialogue event.
func _finish() -> void:
	subtitles.visible = false
	continueIcon.visible = false
	dialogue_finished.emit()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when the player presses the interact button.
func _on_input_handler_interact_button_pressed() -> void:
	loadNextDialogue()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
