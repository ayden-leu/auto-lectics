extends Node3D

var npcTestInitialLocation:Vector3
var moveNpcTest:bool = false

func _ready() -> void:
	FR_MenuManager.disable() # either enable() or disable()
	FR_WindowManager.disable() # either enable() or disable()
	CursorHandler.setDefault("hidden") # refer to documentation or hover over the function for valid values
	CursorHandler.hideNuclear() # either hideNuclear() or showNuclear()

	npcTestInitialLocation = %NPC_Test.global_position

	DebugHud.addChecklistEntry("Pre-configured DeathPlane (red world boundary) works.")
	DebugHud.addChecklistEntry("Test NPC does their respawn logic.")
	DebugHud.addChecklistEntry("Player character does their respawn logic.")
	DebugHud.addChecklistEntry("Custom DeathPlane (orange volume) works.")

func _process(_delta: float) -> void:
	if moveNpcTest:
		%NPC_Test.global_position.y -= 0.1

func _on_move_test_npc_pressed() -> void:
	moveNpcTest = true

func _on_npc_test_respawned() -> void:
	%NPC_Test.global_position = npcTestInitialLocation
	moveNpcTest = false
