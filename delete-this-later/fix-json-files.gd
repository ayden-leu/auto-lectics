extends Node3D

# do NOT use this

func _ready() -> void:
	var fileToFix:String = "res://dialogue_objects/preacher/preacher_Day1Playtest.json"
	var placeToSave:String = "res://dialogue_objects/preacher/"
	
	var json_text := _read_text_file(fileToFix)
	var dialogue_list = JSON.parse_string(json_text)
	
	for object in dialogue_list:
		var file = FileAccess.open(
			placeToSave + object.id + ".json",
			FileAccess.WRITE
		)
		
		var newObj := {}
		# TODO TODO TODO TODO
		# replace all occurances of "next" with "nextID"
		
		if object.has("text"):
			newObj.text = object.text
		
		if object.has("type"):
			newObj.type = object.type
		
		if object.has("writer"):	
			newObj.writeSpeed = object.writer.speed.preset
			newObj.writeSpeedCustom = object.writer.speed.custom
		
		if object.has("options"):
			newObj.options = object.options
		
		var contentToSave = JSON.stringify(newObj, "\t", false)
		file.store_string(contentToSave)



static func _read_text_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		printerr("DialogueLoader: File does not exist: ", path)
		return ""
	
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("DialogueLoader: Could not open file: ", path)
		return ""
	
	return file.get_as_text()
