extends Node
class_name AudioLoader
## Helper script to load audio files from project file structure.

## Loads audio files related to a given ID and loads theem into a given [AudioStreamRandomizer].
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

static func clearAudioRandomizer(audioStream:AudioStreamRandomizer) -> void:
	for i in range(audioStream.streams_count):
		audioStream.remove_stream(0)
