extends Node
class_name AudioLoader

const SFX_PATH:String = "res://sounds/sfx/"

static func loadSFX(id:String, audioStream:AudioStreamRandomizer) -> void:
	if id == "none":
		return
		
	var soundIDPath:String = SFX_PATH + id
	var audioFileNames:PackedStringArray = ResourceLoader.list_directory(soundIDPath)
	
	if audioFileNames.is_empty():
		printerr("AudioLoader: Could not find SFX ID folder: ", id)
	
	for filename in audioFileNames:
		if not filename.ends_with(".wav"):
			continue
		
		var audioFile:AudioStreamWAV = AudioStreamWAV.load_from_file(soundIDPath + "/" + filename)
		audioStream.add_stream(-1, audioFile)
