extends VBoxContainer

@export var presetChooser:OptionButton
@export var valueSetter:SpinBox

var presetToChooserIndex:Dictionary = {}

func _ready() -> void:
	for itemIndex in range(presetChooser.item_count):
		presetToChooserIndex.set(presetChooser.get_item_text(itemIndex).to_lower(), itemIndex)
	
	presetChooser.selected = presetToChooserIndex.medium
	_on_preset_chooser_item_selected(presetChooser.selected)

func getPreset() -> String:
	return presetChooser.get_item_text(presetChooser.selected).to_lower()

func getValue() -> float:
	return valueSetter.value

func _on_preset_chooser_item_selected(index: int) -> void:
	var chosen:String = presetChooser.get_item_text(index).to_lower()
	if chosen == "custom":
		return
	
	valueSetter.value = DialogueDefaults.WRITE_SPEED_PRESETS[chosen]

func _on_value_setter_value_changed(value: float) -> void:	
	match value:
		DialogueDefaults.WRITE_SPEED_PRESETS.slow:
			presetChooser.selected = presetToChooserIndex.slow
		DialogueDefaults.WRITE_SPEED_PRESETS.medium:
			presetChooser.selected = presetToChooserIndex.medium
		DialogueDefaults.WRITE_SPEED_PRESETS.fast:
			presetChooser.selected = presetToChooserIndex.fast
		_:
			presetChooser.selected = presetToChooserIndex.custom
