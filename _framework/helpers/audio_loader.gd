@icon("uid://dvylpsokk73w0")
extends Node
class_name AudioLoader
## A helper class that loads audio files into an [AudioStreamRandomizer] resource.
##
## This helper class can be useful if you want to load multiple sound files into
## an [AudioStreamPlayer]'s [AudioStreamRandomizer] stream, which you may be using
## to making sound events less "repetitive."
##
## [br][br]
## [b]Using:[/b][br]
## This is not a component you add to a scene, but rather a static class that
## can be referred to in code from anywhere.
## [codeblock]
## # Assumption:  You have an AudioStreamPlayer node or a node that inherits
## # from it named "myAudioPlayer"
##
## var myStream:AudioStreamRandomizer = $myAudioPlayer.stream
## # or
## var myStream:AudioStreamRandomizer = AudioStreamRandomizer.new()
## $myAudioPlayer.stream = myStream
##
## AudioLoader.loadSfxFromId("_test_1", myStream)
## # you can also load multiple SFX IDs into multiple AudioStreamPlayers
## # at once using AudioLoader.loadSfxIntoPlayers()
## $myAudioPlayer.play()
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
## [br]
## [b]Other Information:[/b][br]
## Consider using a [SfxEventHandler] if you want to make the process simpler
## and do not care about the position of your [AudioStreamPlayer].

## Where all of the SFX ID folders are stored in the project.
const STORAGE_PATH:String = "res://sounds/sfx/"
## The file type the audio files should be.
const FILE_TYPE:String = ".wav"

## Loads audio files related to a given ID into a given [AudioStreamRandomizer].
## [codeblock]
## var myStream:AudioStreamRandomizer = AudioStreamRandomizer.new()
## # or
## var myStream:AudioStreamRandomizer = $myAudioPlayer.stream
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
## Can be useful if you want to remove the streams from an [AudioStreamRandomizer]
## with a lot of streams in it.
static func clearAudioRandomizer(audioStream:AudioStreamRandomizer) -> void:
	for _i in range(audioStream.streams_count):
		audioStream.remove_stream(0)

## Loads SFX IDs from [code]sfxEventsToLoad[/code] into SFX events in [code]sfxPlayers[/code].
## Useful if you have a bunch of [AudioStreamPlayer]s you want to sounds into.
## [br][br]
## Dictionary setup for [code]sfxEventsToLoad[/code]:
## [codeblock]
## {
## 	"eventID1": "sfxID1",
## 	"eventID2": "sfxID2",
## 	"eventID3": "sfxID3"
## }
## [/codeblock]
## [br]
## Dictionary setup for [code]sfxPlayers[/code]:
## [codeblock]
## # It is assumed that the AudioStreamPlayers in this dictionary already have
## # an AudioStreamRandomizer resource loaded into them
## var sameWithOnesMadeViaCode:AudioStreamPlayer = AudioStreamPlayer.new()
## sameWithOnesMadeViaCode.stream = AudioStreamRandomizer.new()
## {
## 	"eventID1": $node_path_to_AudioStreamPlayer,
## 	"eventID2": %unique_name_accessor_also_works,
## 	"eventID3": sameWithOnesMadeViaCode
## }
## [/codeblock]
static func loadSfxIntoPlayers(sfxEventsToLoad:Dictionary, sfxPlayers:Dictionary) -> void:
	for eventID in sfxEventsToLoad:
		if typeof(eventID) != TYPE_STRING:
			push_error("AudioLoader:  A key of the given sfxEventsToLoad Dictionary is not a string.  It is a ", type_string(typeof(eventID)))
			continue
		elif typeof(sfxEventsToLoad[eventID]) != TYPE_STRING:
			push_error("AudioLoader:  The value of [", eventID, "] in given sfxEventsToLoad Dictionary is not a string.  It is a ", type_string(typeof(sfxEventsToLoad[eventID])))
			continue

		elif sfxEventsToLoad[eventID] == "":
			print("AudioLoader:  Skipping loading of SFX event [", eventID, "]")
			continue
		elif not sfxPlayers.has(eventID):
			push_warning("AudioLoader:  There is no SFX player for SFX event [", eventID, "] in the given sfxPlayers Dictionary.")
			continue
		elif sfxPlayers[eventID] is not AudioStreamPlayer and sfxPlayers[eventID] is not AudioStreamPlayer3D and sfxPlayers[eventID] is not AudioStreamPlayer2D:
			push_error("AudioLoader:  The value of [", eventID, "] in the given sfxPlayers Dictionary is not an AudioStreamPlayer or a type that inherits from it.")
			continue
		elif sfxPlayers[eventID].stream is not AudioStreamRandomizer:
			push_error("AudioLoader:  Loaded player for SFX event [", eventID, "] does not have an AudioStreamRandomizer resource.  It has resource of type [", type_string(typeof(sfxPlayers[eventID].stream)), "]")
			continue

		sfxPlayers[eventID].stop()
		clearAudioRandomizer(sfxPlayers[eventID].stream)
		loadSfxFromId(sfxEventsToLoad[eventID], sfxPlayers[eventID].stream)
