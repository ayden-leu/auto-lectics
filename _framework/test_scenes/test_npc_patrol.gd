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
@onready var player: Node3D = %Player
@onready var respawnPosition: Node3D = %RespawnPosition
@onready var loopNpc: NPC = %LoopNPC
@onready var pingPongNpc: NPC = %PingPongNPC
@onready var waitAtEndNpc: NPC = %WaitAtEndNPC

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	FR_MenuManager.enable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("hidden")
	CursorHandler.hideNuclear()

	DebugHud.clearChecklist()
	DebugHud.addChecklistEntry("An NPC is moving along a patrol path.")
	DebugHud.addChecklistEntry("The NPC turns to face its movement direction while patrolling.")
	DebugHud.addChecklistEntry("The loop NPC wraps back to the start of its path.")
	DebugHud.addChecklistEntry("The loop NPC has a higher patrol speed than the others.")
	DebugHud.addChecklistEntry("The ping-pong NPC reverses direction at each end of its path.")
	DebugHud.addChecklistEntry("The waitAtEnd NPC pauses briefly at each end.")
	DebugHud.addChecklistEntry("NPCs in this scene are added to the NPCs group.")

	_verify_npcs_in_group()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_1"):
		player.position = respawnPosition.position

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _verify_npcs_in_group() -> void:
	var npcs: Array = get_tree().get_nodes_in_group("NPCs")

	if npcs.is_empty():
		DebugHud.addToLog("NPC test scene: No nodes found in NPCs group.", DebugHud.LogType.WARNING)
	else:
		DebugHud.addToLog("NPC test scene: Found " + str(npcs.size()) + " node(s) in NPCs group.", DebugHud.LogType.GOOD)

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
