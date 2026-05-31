extends Control

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
@onready var inputHandler: InputHandler = %InputHandler

@onready var movementLabel: Label = %MovementLabel
@onready var mouseLabel: Label = %MouseLabel
@onready var interactLabel: Label = %InteractLabel
@onready var jumpLabel: Label = %JumpLabel
@onready var respawnLabel: Label = %RespawnLabel
@onready var grappleLabel: Label = %GrappleLabel

@onready var movementToggleButton: Button = %MovementToggleButton
@onready var interactionToggleButton: Button = %InteractionToggleButton
@onready var jumpToggleButton: Button = %JumpToggleButton
@onready var respawnToggleButton: Button = %RespawnToggleButton

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
var _movementEnabled: bool = true
var _interactionEnabled: bool = true
var _jumpEnabled: bool = true
var _respawnEnabled: bool = true

var _interactCount: int = 0
var _jumpCount: int = 0
var _respawnCount: int = 0
var _grappleCount: int = 0

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("shown")
	CursorHandler.showNuclear()

	DebugHud.clearChecklist()
	DebugHud.addChecklistEntry("Movement keys update the movement direction label.")
	DebugHud.addChecklistEntry("Moving the mouse updates the mouse movement label.")
	DebugHud.addChecklistEntry("Pressing interact updates the interact label.")
	DebugHud.addChecklistEntry("Pressing jump updates the jump label.")
	DebugHud.addChecklistEntry("Pressing respawn updates the respawn label.")
	DebugHud.addChecklistEntry("Pressing grapple updates the grapple label.")
	DebugHud.addChecklistEntry("Disabling movement makes the movement direction show (0,0).")
	DebugHud.addChecklistEntry("Disabling interaction prevents the interact label from updating.")
	DebugHud.addChecklistEntry("Disabling jump prevents the jump label from updating.")
	DebugHud.addChecklistEntry("Disabling respawn prevents the respawn label from updating.")

	inputHandler.update_input_direction.connect(_on_input_handler_update_input_direction)
	inputHandler.mouse_moved.connect(_on_input_handler_mouse_moved)
	inputHandler.interact_button_pressed.connect(_on_input_handler_interact_button_pressed)
	inputHandler.jump_pressed.connect(_on_input_handler_jump_pressed)
	inputHandler.respawn.connect(_on_input_handler_respawn)
	inputHandler.grapple_pressed.connect(_on_input_handler_grapple_pressed)

	movementToggleButton.pressed.connect(_on_movement_toggle_button_pressed)
	interactionToggleButton.pressed.connect(_on_interaction_toggle_button_pressed)
	jumpToggleButton.pressed.connect(_on_jump_toggle_button_pressed)
	respawnToggleButton.pressed.connect(_on_respawn_toggle_button_pressed)

	_reset_input_state()
	_update_toggle_button_text()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _reset_input_state() -> void:
	InputHandler.enableMovementInputGlobal()
	InputHandler.enableInteractionInputGlobal()
	InputHandler.enableJumpInputGlobal()
	InputHandler.enableRespawnInputGlobal()

	_movementEnabled = true
	_interactionEnabled = true
	_jumpEnabled = true
	_respawnEnabled = true

	movementLabel.text = "Movement Direction: Vector2.ZERO"
	mouseLabel.text = "Mouse Movement: move mouse to test"
	interactLabel.text = "Interact Pressed: 0"
	jumpLabel.text = "Jump Pressed: 0"
	respawnLabel.text = "Respawn Pressed: 0"
	grappleLabel.text = "Grapple Pressed: 0"


func _update_toggle_button_text() -> void:
	movementToggleButton.text = "Movement: ON" if _movementEnabled else "Movement: OFF"
	interactionToggleButton.text = "Interaction: ON" if _interactionEnabled else "Interaction: OFF"
	jumpToggleButton.text = "Jump: ON" if _jumpEnabled else "Jump: OFF"
	respawnToggleButton.text = "Respawn: ON" if _respawnEnabled else "Respawn: OFF"

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_input_handler_update_input_direction(newDirection: Vector2) -> void:
	movementLabel.text = "Movement Direction: " + str(newDirection)


func _on_input_handler_mouse_moved(distanceMoved: Vector2) -> void:
	mouseLabel.text = "Mouse Movement: " + str(distanceMoved)


func _on_input_handler_interact_button_pressed() -> void:
	_interactCount += 1
	interactLabel.text = "Interact Pressed: " + str(_interactCount)


func _on_input_handler_jump_pressed() -> void:
	_jumpCount += 1
	jumpLabel.text = "Jump Pressed: " + str(_jumpCount)


func _on_input_handler_respawn() -> void:
	_respawnCount += 1
	respawnLabel.text = "Respawn Pressed: " + str(_respawnCount)


func _on_input_handler_grapple_pressed() -> void:
	_grappleCount += 1
	grappleLabel.text = "Grapple Pressed: " + str(_grappleCount)


func _on_movement_toggle_button_pressed() -> void:
	_movementEnabled = not _movementEnabled

	if _movementEnabled:
		InputHandler.enableMovementInputGlobal()
	else:
		InputHandler.disableMovementInputGlobal()

	_update_toggle_button_text()


func _on_interaction_toggle_button_pressed() -> void:
	_interactionEnabled = not _interactionEnabled

	if _interactionEnabled:
		InputHandler.enableInteractionInputGlobal()
	else:
		InputHandler.disableInteractionInputGlobal()

	_update_toggle_button_text()


func _on_jump_toggle_button_pressed() -> void:
	_jumpEnabled = not _jumpEnabled

	if _jumpEnabled:
		InputHandler.enableJumpInputGlobal()
	else:
		InputHandler.disableJumpInputGlobal()

	_update_toggle_button_text()


func _on_respawn_toggle_button_pressed() -> void:
	_respawnEnabled = not _respawnEnabled

	if _respawnEnabled:
		InputHandler.enableRespawnInputGlobal()
	else:
		InputHandler.disableRespawnInputGlobal()

	_update_toggle_button_text()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
