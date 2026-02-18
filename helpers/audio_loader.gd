extends Node
class_name AudioLoader

const SFX_PATH:String = "res://sounds/sfx/"

static func loadAudioFiles(id:String, audioStream:AudioStreamRandomizer) -> void:
	if id == "none":
		return
		
	var tempDirAccess:DirAccess = DirAccess.open(SFX_PATH)
	if not tempDirAccess.dir_exists(id):
		printerr("AudioLoader: Could not find the SFX ID folder: ", id)
	
	var soundIDPath:String = SFX_PATH + id
	var audioFileNames:PackedStringArray = ResourceLoader.list_directory(soundIDPath)
	if audioFileNames.is_empty():
		printerr("AudioLoader: Could not find any SFX in SFX ID folder: ", id)
	
	for filename in audioFileNames:
		if not filename.ends_with(".wav"):
			continue
		
		var audioFile:AudioStreamWAV = AudioStreamWAV.load_from_file(soundIDPath + "/" + filename)
		audioStream.add_stream(-1, audioFile)

static func clearAudioFiles(audioStream:AudioStreamRandomizer) -> void:
	for i in range(audioStream.streams_count):
		audioStream.remove_stream(0)
