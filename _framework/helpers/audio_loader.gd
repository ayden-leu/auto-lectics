extends Node
class_name AudioLoader
## Helper script to load audio files from project file structure.

## Loads audio files related to a given ID and loads them into a given [AudioStreamRandomizer].
static func loadSfxFromId(id:String, audioStream:AudioStreamRandomizer) -> int:
	if id == "":
		printerr("AudioLoader: No ID provided.")
		return -1

	if id == "none":
		return 0

	var tempDirAccess:DirAccess = DirAccess.open(FR_Globals.STORAGE_PATH.SFX)
	if not tempDirAccess.dir_exists(id):
		printerr("AudioLoader: Could not find the SFX ID folder: ", id)
		return -2

	var soundIDPath:String = FR_Globals.STORAGE_PATH.SFX + id
	var audioFileNames:PackedStringArray = ResourceLoader.list_directory(soundIDPath)
	if audioFileNames.is_empty():
		printerr("AudioLoader: Could not find any SFX in SFX ID folder: ", id)
		return -3

	for filename in audioFileNames:
		if not filename.ends_with(".wav"):
			continue

		var audioFile:AudioStreamWAV = load(soundIDPath + "/" + filename)
		audioStream.add_stream(-1, audioFile)

	return 0

## Clears the entries in an [AudioStreamRandomizer].
static func clearAudioRandomizer(audioStream:AudioStreamRandomizer) -> void:
	for i in range(audioStream.streams_count):
		audioStream.remove_stream(0)

## Loads SFX IDs from [code]sfxEventsToLoad[/code] into SFX events in [code]sfxPlayers[/code].
## [br][br]
## Dictionary setup for [code]sfxEventsToLoad[/code]:
## [codeblock]
## {
## 	"eventID1": "sfxID1",
## 	"eventID2": "sfxID2"
## }
## [/codeblock]
## [br][br]
## Dictionary setup for [code]sfxPlayers[/code]:
## [codeblock]
## {
## 	"eventID1": $path_to_AudioStreamPlayer,
## 	"eventID2": %unique_name_also_works
## }
## [/codeblock]
static func loadSfxIntoPlayers(sfxEventsToLoad:Dictionary, sfxPlayers:Dictionary[String, AudioStreamPlayer]) -> void:
	for eventID in sfxEventsToLoad:
		if typeof(sfxEventsToLoad[eventID]) != TYPE_STRING:
			printerr("AudioLoader: sfxEventsToLoad value at entry [" + eventID +
				"] isn't a string.  Is [" + type_string(sfxEventsToLoad[eventID]) + "]"
			)
			continue
		elif sfxEventsToLoad[eventID] == "":
			print("AudioLoader:  Skipping loading of SFX event \"" + eventID + "\"")
			continue
		elif not sfxPlayers.has(eventID):
			printerr("AudioLoader:  There is no SFX player for SFX event\"" + eventID + "\"")
			continue

		sfxPlayers[eventID].stop()
		clearAudioRandomizer(sfxPlayers[eventID].stream)
		loadSfxFromId(sfxEventsToLoad[eventID], sfxPlayers[eventID].stream)
