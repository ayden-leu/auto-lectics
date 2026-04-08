@tool
extends Label3D
class_name TypeWriterLabel3D
## A [Label3D] with the ability to show only a certain amount of characters.

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The full string of text that will be displayed when `visibleRatio` is set to 1.0. To get the text that's currently visible, use `text`
@export var fullText:String = ""
## It's like [member Label.visible_characters]. Some edge cases may not act the same, probably.
## The number of characters to display. If set to -1, all characters are displayed. This can be useful when animating the text appearing in a dialog box.[br][br]
## Setting this property updates [member visibleRatio] accordingly.
@export_range(-1, 10000) var visibleCharacters:int = -1:
	set(value):
		visibleCharacters = value
		_updateText()
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
## It's like [member Label.visible_ratio]. Some edge cases may not act the same, probably.
## The fraction of characters to display, relative to the total number of characters. If set to 1.0, all characters are displayed. If set to 0.5, only half of the characters will be displayed. This can be useful when animating the text appearing in a dialog box.[br][br]
## Setting this property updates [member visibleCharacters] accordingly.
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

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Used to stop the cyclic setting of `visibleCharacters` and `visibleRatio`.
var _stopSetting:bool = false
## [b]Internal-use only.[/b]  Used to stop the cyclic setting of `visibleCharacters` and `visibleRatio`.
var _goingToStopSetting:bool = false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	visibleCharacters = visibleCharacters

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _updateText() -> void:
	var amount:int = fullText.length() if (visibleCharacters == -1) else visibleCharacters
	text = fullText.substr(0, amount)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
