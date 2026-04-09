extends Area2D

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
const _OFFSET_FROM_MOUSE:Vector2 = Vector2(-5, -5)

# ------------------------------------------------
# export variables
# ------------------------------------------------
@export var contents:Control

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
var _mouseHovering:bool = false
var _mouseDragging:bool = false

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
#func _ready() -> void:
	#pass

func _process(_delta: float) -> void:
	if _mouseHovering and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_mouseDragging = true
	elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_mouseDragging = false
	
	if _mouseDragging:
		contents.global_position = get_global_mouse_position() + _OFFSET_FROM_MOUSE

#func _physics_process(delta: float) -> void:
	#super(delta)  # needed if inheriting a custom class with its own _physics_process().  Will run the inherited class' _physics_process() function.

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_mouse_entered_area() -> void:
	_mouseHovering = true

func _on_mouse_exited_area() -> void:
	_mouseHovering = false

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
