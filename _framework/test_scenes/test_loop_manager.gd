extends Node3D

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
@onready var player: Player = %Player
@onready var respawnPosition: Marker3D = %RespawnPosition

@onready var manualLoopManager: LoopManager = %ManualLoopManager
@onready var timerLoopManager: LoopManager = %TimerLoopManager

@onready var restartArea: RestartLoopManagerArea3D = %RestartLoopManagerArea3D
@onready var restartAreaVisual: MeshInstance3D = %RestartAreaVisual

@onready var statusLabel: Label = %StatusLabel
@onready var radiusLabel: Label = %RadiusLabel
@onready var resetCountLabel: Label = %ResetCountLabel
@onready var timerCountdownLabel: Label = %TimerCountdownLabel

@onready var normalResetButton: Button = %NormalResetButton
@onready var fancyResetButton: Button = %FancyResetButton
@onready var timerToggleButton: Button = %TimerToggleButton

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
var _manualResetCount: int = 0
var _timerResetCount: int = 0
var _fancyCollisionCount: int = 0

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("shown")
	CursorHandler.showNuclear()
	
	DebugHud.clearChecklist()
	DebugHud.addChecklistEntry("Pressing Normal Reset makes the LoopManager overlay fade in and out.")
	DebugHud.addChecklistEntry("Normal Reset emits resetting, do_reset, and reset_finished.")
	DebugHud.addChecklistEntry("Pressing Expanding Reset makes RestartLoopManagerArea3D begin expanding.")
	DebugHud.addChecklistEntry("When the expanding area reaches the player, the player respawns.")
	DebugHud.addChecklistEntry("After Expanding Reset finishes, RestartLoopManagerArea3D returns to radius 0.")
	DebugHud.addChecklistEntry("The timer automatically starts a normal reset after its countdown reaches 0.")
	DebugHud.addChecklistEntry("The timer countdown decreases while the scene runs.")
	DebugHud.addChecklistEntry("After an automatic reset finishes, the timer starts counting down again.")
	DebugHud.addChecklistEntry("The status labels update without needing console output.")
	
	_configureLoopManagersForTest()
	_connectSignals()
	
	_resetPlayerToStart()
	_updateStatus("Ready. Press Normal Reset or Expanding Reset. Timer reset should also happen automatically.")
	_updateResetCountLabel()
	timerLoopManager._timer.paused = true


func _process(_delta: float) -> void:
	_updateRadiusLabel()
	_updateRestartAreaVisual()
	_updateTimerCountdownLabel()

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _configureLoopManagersForTest() -> void:
	# ManualLoopManager is used for button-triggered normal and fancy resets.
	manualLoopManager.manual = true
	manualLoopManager.fancy = true
	manualLoopManager.fancyArea = restartArea

	# TimerLoopManager should be configured in the inspector:
	# manual = false
	# fancy = false
	# loopDurationSeconds = something short, e.g. 5.0
	#
	# Its timer is created and started in LoopManager._ready(), so set those
	# exported values in the inspector before running the scene.


func _connectSignals() -> void:
	normalResetButton.pressed.connect(_on_normal_reset_button_pressed)
	fancyResetButton.pressed.connect(_on_fancy_reset_button_pressed)
	timerToggleButton.pressed.connect(_on_timer_toggle_button_pressed)
	
	manualLoopManager.resetting.connect(_on_manual_loop_manager_resetting)
	manualLoopManager.do_reset.connect(_on_manual_loop_manager_do_reset)
	manualLoopManager.reset_finished.connect(_on_manual_loop_manager_reset_finished)
	
	timerLoopManager.resetting.connect(_on_timer_loop_manager_resetting)
	timerLoopManager.do_reset.connect(_on_timer_loop_manager_do_reset)
	timerLoopManager.reset_finished.connect(_on_timer_loop_manager_reset_finished)
	
	restartArea.collided_with_player.connect(_on_restart_area_collided_with_player)


func _resetPlayerToStart() -> void:
	player.global_position = respawnPosition.global_position


func _updateStatus(message: String) -> void:
	statusLabel.text = "Status: " + message
	DebugHud.addToLog(message)


func _updateRadiusLabel() -> void:
	if restartArea.collision == null:
		radiusLabel.text = "Restart Area Radius: collision missing"
		return
	if restartArea.collision.shape == null:
		radiusLabel.text = "Restart Area Radius: shape missing"
		return
	if not restartArea.collision.shape is SphereShape3D:
		radiusLabel.text = "Restart Area Shape: " + restartArea.collision.shape.get_class()
		return
	
	var sphere: SphereShape3D = restartArea.collision.shape as SphereShape3D
	radiusLabel.text = "Restart Area Radius: " + str(snapped(sphere.radius, 0.01))


func _updateRestartAreaVisual() -> void:
	if restartArea.collision == null:
		return
	if restartArea.collision.shape == null:
		return
	if not restartArea.collision.shape is SphereShape3D:
		return
	
	var sphere: SphereShape3D = restartArea.collision.shape as SphereShape3D
	var radius: float = sphere.radius
	restartAreaVisual.global_position = restartArea.global_position
	restartAreaVisual.scale = Vector3.ONE * max(radius * 2.0, 0.01)


func _updateTimerCountdownLabel() -> void:
	if timerLoopManager == null:
		timerCountdownLabel.text = "Auto Reset Countdown: missing TimerLoopManager"
		return
	
	var pausedText: String = ""
	if timerLoopManager._timer != null and timerLoopManager._timer.paused:
		pausedText = " (PAUSED)"
	
	timerCountdownLabel.text = "Auto Reset Countdown: " \
		+ str(snapped(timerLoopManager.resetProgressSeconds, 0.01)) \
		+ pausedText


func _updateResetCountLabel() -> void:
	resetCountLabel.text = "Manual Resets: " + str(_manualResetCount) \
		+ " | Timer Resets: " + str(_timerResetCount) \
		+ " | Expanding Collisions: " + str(_fancyCollisionCount)


func _setButtonsEnabled(enabled: bool) -> void:
	normalResetButton.disabled = not enabled
	fancyResetButton.disabled = not enabled

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_normal_reset_button_pressed() -> void:
	_setButtonsEnabled(false)
	_updateStatus("Manual Normal Reset requested. ManualLoopManager overlay should fade in.")
	await manualLoopManager.performNormalReset()
	_setButtonsEnabled(true)


func _on_fancy_reset_button_pressed() -> void:
	_setButtonsEnabled(false)
	restartArea.reset()
	_updateStatus("Manual Expanding Reset requested. Restart area should begin growing.")
	await manualLoopManager.performFancyReset()
	_setButtonsEnabled(true)


func _on_timer_toggle_button_pressed() -> void:
	timerLoopManager._timer.paused = not timerLoopManager._timer.paused
	
	if timerLoopManager._timer.paused:
		timerToggleButton.text = "Resume Timer"
		_updateStatus("TimerLoopManager countdown paused.")
	else:
		timerToggleButton.text = "Pause Timer"
		_updateStatus("TimerLoopManager countdown resumed.")


func _on_manual_loop_manager_resetting() -> void:
	_updateStatus("ManualLoopManager emitted resetting.")


func _on_manual_loop_manager_do_reset() -> void:
	_updateStatus("ManualLoopManager emitted do_reset.")


func _on_manual_loop_manager_reset_finished() -> void:
	_manualResetCount += 1
	_updateResetCountLabel()
	_updateStatus("ManualLoopManager emitted reset_finished.")


func _on_timer_loop_manager_resetting() -> void:
	_updateStatus("TimerLoopManager emitted resetting automatically.")


func _on_timer_loop_manager_do_reset() -> void:
	_updateStatus("TimerLoopManager emitted do_reset automatically.")


func _on_timer_loop_manager_reset_finished() -> void:
	_timerResetCount += 1
	_updateResetCountLabel()
	_updateStatus("TimerLoopManager emitted reset_finished and should restart countdown.")


func _on_restart_area_collided_with_player(_player: Player) -> void:
	_fancyCollisionCount += 1
	_updateResetCountLabel()
	_updateStatus("RestartLoopManagerArea3D collided with Player.")

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
