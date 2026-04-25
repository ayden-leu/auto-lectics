extends Control

@onready var label: Label = $DialogueLabel

func _ready() -> void:
	var data:Dictionary = FR_Globals.getDialogueNode("_test_font", "continue")
	label.text = data.text
	label.label_settings = LabelPresetLoader.loadPreset(data.font)
