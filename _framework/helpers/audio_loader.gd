extends Node
class_name AudioLoader
## A helper class that loads audio files into an [AudioStreamRandomizer].
##
## This is not a component you add to a scene, but rather a static class that
## can be referred to in code from anywhere.
## [codeblock]
## var myStream:AudioStreamRandomizer = AudioStreamRandomizer.new()
## AudioLoader.loadSfxFromId("_test_1", myAudioStreamRandomizer)
## $AudioStreamPlayer.stream = myStream
## $AudioStreamPlayer.play()
## [/codeblock]
## Audio files that can be loaded by this class are located in subfolders
## located in [member STORAGE_PATH].
## The name of a subfolder corresponds to SFX ID.
## The names of each audio file do not matter, however their file extension/type
## should be of type [member FILE_TYPE].
## [codeblock lang=text]
## STORAGE_PATH
##  └── sfx
##      ├── _test_1
##      │   ├── file1.FILE_TYPE
##      │   ├── file2.FILE_TYPE
##      │   ├── file3.FILE_TYPE
##      ├── _test_2
##      │   └── file1.FILE_TYPE
##      └── _test_3
##          └── file1.FILE_TYPE
## [/codeblock]

## Where all of the SFX ID folders are stored in the project.
const STORAGE_PATH:String = "res://sounds/sfx/"
## The file type the audio files should be.
const FILE_TYPE:String = ".wav"

## Loads audio files related to a given ID and loads them into a given [AudioStreamRandomizer].
## [codeblock]
## var myStream:AudioStreamRandomizer = AudioStreamRandomizer.new()
##
## # a subfolder named "_test_1" with audio files exists.
## var result = AudioLoader.loadSfxFromId("_test_1", myAudioStreamRandomizer)
## # result = Error.OK, success
##
## # a subfolder named "empty" exists but has no audio files.
## var result = AudioLoader.loadSfxFromId("empty", myAudioStreamRandomizer)
## # result = Error.ERR_DOES_NOT_EXIST, warning pushed
##
## # a subfolder named "chair" does not exist.
## var result = AudioLoader.loadSfxFromId("chair", myAudioStreamRandomizer)
## # result = Error.ERR_DOES_NOT_EXIST, warning pushed
##
## [/codeblock]
static func loadSfxFromId(id:String, audioStream:AudioStreamRandomizer) -> Error:
	if id == "":
		push_warning("AudioLoader: No ID provided. Doing nothing now.")
		return Error.ERR_INVALID_DATA

	if id == "none":
		return Error.OK

	var tempDirAccess:DirAccess = DirAccess.open(STORAGE_PATH)
	if not tempDirAccess.dir_exists(id):
		push_warning("AudioLoader: Could not find the SFX ID folder: [", id, "]. Doing nothing now.")
		return Error.ERR_DOES_NOT_EXIST

	var soundIDPath:String = STORAGE_PATH + id
	var audioFileNames:PackedStringArray = ResourceLoader.list_directory(soundIDPath)
	var hasAudioFiles:bool = false
	for filename in audioFileNames:
		if filename.ends_with(FILE_TYPE):
			hasAudioFiles = true
			break
	if not hasAudioFiles:
		push_warning("AudioLoader: Could not find any valid audio files in SFX ID folder: [", id, "]. Doing nothing now.")
		return Error.ERR_DOES_NOT_EXIST

	for filename in audioFileNames:
		if not filename.ends_with(FILE_TYPE):
			continue

		var audioFile:AudioStreamWAV = load(soundIDPath + "/" + filename)
		audioStream.add_stream(-1, audioFile)

	return Error.OK

## Removes all stream entries in an [AudioStreamRandomizer].
static func clearAudioRandomizer(audioStream:AudioStreamRandomizer) -> void:
	for _i in range(audioStream.streams_count):
		audioStream.remove_stream(0)

## Loads SFX IDs from [code]sfxEventsToLoad[/code] into SFX events in [code]sfxPlayers[/code].
## [br][br]
## Dictionary setup for [code]sfxEventsToLoad[/code]:
## [codeblock]
## {
## 	"eventID1": "sfxID1",
## 	"eventID2": "sfxID2",
## }
## [/codeblock]
## [br]
## Dictionary setup for [code]sfxPlayers[/code]:
## [codeblock]
## {
## 	"eventID1": $node_path_to_AudioStreamPlayer,
## 	"eventID2": %unique_name_also_works
## }
## [/codeblock]
static func loadSfxIntoPlayers(sfxEventsToLoad:Dictionary, sfxPlayers:Dictionary[String, AudioStreamPlayer]) -> void:
	for eventID in sfxEventsToLoad:
		if typeof(sfxEventsToLoad[eventID]) != TYPE_STRING:
			push_warning("AudioLoader:  sfxEventsToLoad value at entry [", eventID,
				"] isn't a string.  It is of type [", type_string(typeof(sfxEventsToLoad[eventID])), "]."
			)
			continue
		elif sfxEventsToLoad[eventID] == "":
			print("AudioLoader:  Skipping loading of SFX event [", eventID, "]")
			continue
		elif not sfxPlayers.has(eventID):
			push_warning("AudioLoader:  There is no SFX player for SFX event [", eventID, "]")
			continue
		elif sfxPlayers[eventID].stream is not AudioStreamRandomizer:
			push_warning("AudioLoader:  Loaded player for SFX event [", eventID, "] does not have an AudioStreamRandomizer resource.  It has resource of type [", type_string(typeof(sfxPlayers[eventID].stream)), "]")
			continue

		sfxPlayers[eventID].stop()
		clearAudioRandomizer(sfxPlayers[eventID].stream)
		loadSfxFromId(sfxEventsToLoad[eventID], sfxPlayers[eventID].stream)
