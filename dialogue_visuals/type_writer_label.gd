@tool
extends Label3D
class_name TypeWriterLabel

## It's like the corresponding property of the Label control node. Some edge cases may not act the same, probably.
## The number of characters to display. If set to -1, all characters are displayed. This can be useful when animating the text appearing in a dialog box.
## Note: Setting this property updates visible_ratio accordingly.
@export_range(-1, 10000) var visibleCharacters:int = -1:
	set(value):
		visibleCharacters = value
		updateText()
		if _goingToStopSetting:
			_stopSetting = true
			_goingToStopSetting = false
		if not _stopSetting:
			_goingToStopSetting = true
			if value == -1:
				visibleRatio = 1.0
			else:
				visibleRatio = value * 1.0 / fullText.length()
			_stopSetting = true
		else:
			_stopSetting = false
## It's like the corresponding property of the Label control node. Some edge cases may not act the same, probably.
## The fraction of characters to display, relative to the total number of characters. If set to 1.0, all characters are displayed. If set to 0.5, only half of the characters will be displayed. This can be useful when animating the text appearing in a dialog box.
## Note: Setting this property updates visible_characters accordingly.
@export_range(0.0, 1.0) var visibleRatio:float = 1.0:
	set(value):
		visibleRatio = value
		if _goingToStopSetting:
			_stopSetting = true
			_goingToStopSetting = false
		if not _stopSetting:
			_goingToStopSetting = true
			if visibleRatio == 1.0:
				visibleCharacters = -1
			else:
				visibleCharacters = roundi(fullText.length() * value)
			_stopSetting = true
		else:
			_stopSetting = false
## Internal variable used to stop the cyclic setting of `visibleCharacters` and `visibleRatio`.
var _stopSetting:bool = false
## Internal variable used to stop the cyclic setting of `visibleCharacters` and `visibleRatio`.
var _goingToStopSetting:bool = false

## The full string of text that will be displayed when `visibleRatio` is set to 1.0. To get the text that's currently visible, use `text`
@export var fullText:String = ""

func _ready() -> void:
	visibleCharacters = visibleCharacters

func updateText() -> void:
	var amount:int = fullText.length() if (visibleCharacters == -1) else visibleCharacters
	text = fullText.substr(0, amount)
