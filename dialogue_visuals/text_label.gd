@tool
extends Label3D

## It's like the corresponding property of the Label control node. Some edge cases may not act the same, probably.
## The number of characters to display. If set to -1, all characters are displayed. This can be useful when animating the text appearing in a dialog box.
## Note: Setting this property updates visible_ratio accordingly.
@export var visibleCharacters:int = -1
## It's like the corresponding property of the Label control node. Some edge cases may not act the same, probably.
## The fraction of characters to display, relative to the total number of characters. If set to 1.0, all characters are displayed. If set to 0.5, only half of the characters will be displayed. This can be useful when animating the text appearing in a dialog box.
## Note: Setting this property updates visible_characters accordingly.
@export_range(0.0, 1.0) var visibleRatio:float = 1.0

## The full string of text that will be displayed when `visibleRatio` is set to 1.0. To get the text that's currently visible, use `text`
var fullText:String = ""

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
