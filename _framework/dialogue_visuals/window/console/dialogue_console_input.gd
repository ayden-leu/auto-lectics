extends LineEdit

# feel free to remove sections you're not using
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

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Determines if the given position is on this node.
# Credit:  user csujin from https://forum.godotengine.org/t/how-to-click-out-of-line-edit/22591/3
func _is_pos_in(checkpos:Vector2):
	var gr=get_global_rect()
	return checkpos.x>=gr.position.x and checkpos.y>=gr.position.y and checkpos.x<gr.end.x and checkpos.y<gr.end.y

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _input(event:InputEvent) -> void:
	# Credit:  user csujin from https://forum.godotengine.org/t/how-to-click-out-of-line-edit/22591/3
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		release_focus()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when this is focused.
func _on_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:
		FR_WindowManager.disableKeybinds()
	else:
		FR_WindowManager.enableKeybinds()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
