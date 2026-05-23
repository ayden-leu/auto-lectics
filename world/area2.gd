extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	if $FadeToBlackHitbox.shouldIReloadTheScene == true:
#		get_tree().reload_current_scene()






func _ready() -> void:
	FR_MenuManager.enable() # either enable() or disable()
	FR_WindowManager.enable() # either enable() or disable()
	CursorHandler.setDefault("hidden") # refer to documentation or hover over the function for valid values
	CursorHandler.hideNuclear() # either hideNuclear() or showNuclear()

# ---------------------------------------------------------------
# uncomment the below code if you want the `open_gate` command
# to work regardless of who opened the DialogueConsole
# ---------------------------------------------------------------

#func _on_console_command_entered(command:String) -> void:
	#if command == "open_gate":
		#$npcs/miniboss2/gateNode.open_gate()
