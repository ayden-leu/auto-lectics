extends Node

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
@onready var _bpCorrectGuess: Label = %BP_CorrectGuess
@onready var _bpUnlockMet: Label = %BP_UnlockMet

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	FR_MenuManager.enable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("shown")
	CursorHandler.showNuclear()
	FR_MenuManager.subscribeToBlueprintMenu(self)

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
func _on_blueprint_npc_name_guessed_correctly(npcID:String) -> void:
	_bpCorrectGuess.text = npcID

func _on_blueprint_unlock_condition_met(conditionID:String) -> void:
	_bpUnlockMet.text = conditionID

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
