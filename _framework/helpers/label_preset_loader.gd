@icon("uid://mjaagygagbwl")
extends Object
class_name LabelPresetLoader
## Loads saved [LabelSettings] presets into [Label]s.
##
## This helper is mainly here so [LabelSettings] resources can easily be retrieved
## via code without having to manually set references to each preset file.
## [br][br][br]
## [b]Use Case:[/b][br]
## When you need to swap out the [member Label.label_settings] for a label via code.
## An example would be changing the font of a [DialogueWindow]'s header when a button
## in the window is pressed.
## [br][br][br]
## [b]Using:[/b]
## [codeblock]
## # Assumption:  you have a Label node named "MyLabel" as a child of your node.
## var preset:LabelSettings = LabelPresetLoader.loadPreset("_test")
## $MyLabel.label_settings = preset
## [/codeblock]
## [br]
## Presets are stored in [member FR_Globals.STORAGE_PATH] and have the [member FILE_TYPE] file extension/type.
## The name of the file without the extension/type is what is passed into [method loadPreset].

## The storage location for all [LabelSettings] resources.
const STORAGE_PATH:String = "res://fonts/_label_presets/"
## The file type of the [LabelSettings] resources.
const FILE_TYPE:String = ".tres"

## Loads the given preset.  Storage path can be found in [member FR_Blobals.STORAGE_PATH].
## [br][br]
## Will return [code]null[/code] if:[br]
## - The given preset is nothing (spaces, newlines, tabs).[br]
## - The file for the given preset doesn't exist.[br]
## - The file for the given preset isn't a [LabelSettings] resource.
static func loadPreset(preset:String) -> LabelSettings:
	preset = preset.strip_edges()
	if preset.is_empty():
		return null

	var path:String = STORAGE_PATH + preset + FILE_TYPE
	if not ResourceLoader.exists(path):
		DebugHud.addToLog("Label preset not found: %s" % path, DebugHud.LogType.ERROR)
		return null

	var resource := load(path)
	if resource is LabelSettings:
		return resource

	DebugHud.addToLog("Resource exists but is not a LabelSettings: %s" % path, DebugHud.LogType.ERROR)
	return null
