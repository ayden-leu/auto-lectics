@icon("uid://mjaagygagbwl")
extends Object
class_name LabelPresetLoader
## Loads label preset resources into [Label]s via code.

## The storage location for all [LabelSettings] resources.
const STORAGE_PATH:String = "res://fonts/_label_presets/"
## The file type of the [LabelSettings] resources.
const FILE_TYPE:String = ".tres"

## Loads the given preset.  Storage path can be found in [member FR_Blobals.STORAGE_PATH].
static func loadPreset(preset:String) -> LabelSettings:
	preset = preset.strip_edges()
	if preset.is_empty():
		return null

	var path:String = STORAGE_PATH + preset + FILE_TYPE
	if not ResourceLoader.exists(path):
		printerr("Label preset not found: %s" % path)
		return null

	var resource := load(path)
	if resource is LabelSettings:
		return resource

	printerr("Resource exists but is not a LabelSettings: %s" % path)
	return null
