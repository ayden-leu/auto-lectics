extends DC_AspectsFlags
class_name DC_AspectsCheckFlags
## [b]Internal-use only.[/b]  Check [DC_AspectsFlags] for functionality.

func _ready() -> void:
	_storyFlagScene = preload("uid://b7qu1lm6jcww2")
	super()

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_add_button_pressed() -> void:
	super()

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_flag_field_removed(field:DC_StoryFlagFieldOption) -> void:
	super(field)

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_flag_field_updated(oldFlagID:String, newFlagID:String) -> void:
	super(oldFlagID, newFlagID)
