extends Node
class_name AudioLoader
## Helper script to load audio files from project file structure.

## Loads audio files related to a given ID and loads theem into a given [AudioStreamRandomizer].
static func loadSfxFromId(id:String, audioStream:AudioStreamRandomizer) -> void:
	if id == "none":
		return
		
	var tempDirAccess:DirAccess = DirAccess.open(Globals.STORAGE_PATH.SFX)
	if not tempDirAccess.dir_exists(id):
		printerr("AudioLoader: Could not find the SFX ID folder: ", id)
	
	var soundIDPath:String = Globals.STORAGE_PATH.SFX + id
	var audioFileNames:PackedStringArray = ResourceLoader.list_directory(soundIDPath)
	if audioFileNames.is_empty():
		printerr("AudioLoader: Could not find any SFX in SFX ID folder: ", id)
	
	for filename in audioFileNames:
		if not filename.ends_with(".wav"):
			continue
		
		var audioFile:AudioStreamWAV = load(soundIDPath + "/" + filename)
		audioStream.add_stream(-1, audioFile)

static func clearAudioRandomizer(audioStream:AudioStreamRandomizer) -> void:
	for i in range(audioStream.streams_count):
		audioStream.remove_stream(0)
