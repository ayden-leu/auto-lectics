extends Node

@export var overlay: FadeToBlackOverlay
@export var status_label: Label

func _ready() -> void:
	if not overlay:
		push_error("FadeToBlackOverlayTest: overlay is not assigned.")
		return

	overlay.fade_in_complete.connect(_on_fade_in_complete)
	overlay.fade_out_complete.connect(_on_fade_out_complete)

	status_label.text = "Press F to fade in. Press G to fade out. Press R to reset."


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			status_label.text = "Fading in..."
			overlay.startFadeIn()

		elif event.keycode == KEY_G:
			status_label.text = "Fading out..."
			overlay.startFadeOut()

		elif event.keycode == KEY_R:
			status_label.text = "Reset overlay."
			overlay.reset()


func _on_fade_in_complete() -> void:
	status_label.text = "Fade in complete."


func _on_fade_out_complete() -> void:
	status_label.text = "Fade out complete."
