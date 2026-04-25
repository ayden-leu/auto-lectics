extends Control

@onready var label: Label = $DialogueLabel

var preset:String = "_test"

func _ready() -> void:
	label.label_settings = LabelPresetLoader.loadPreset(preset)
