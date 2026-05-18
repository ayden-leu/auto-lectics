@tool
@icon("uid://b105kdcrwpi0r")
extends NPC
class_name InteractableNPC
## The base class of all Interactable NPCs in the game.  Interactable NPCs allow the player to interact with them and initiate a dialogue event.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when a dialogue entry is fully displayed.
signal dialogue_all_visible()
## Emitted when a dialogue option is spawned.
signal option_available()
## Emitted when all dialogue options have been spawned.
signal all_options_available()
## Emitted when the next node in the dialogue tree is loaded.
signal dialogue_advanced()
## Emitted when the dialogue tree reaches an end.
signal finished_dialogue()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The hitbox of this Interactable NPC.
## Used to allow players to interact with this InteractableNPC.
@export var _hitbox:Area3D
## If this InteractableNPC should only respond to interactions once.
@export var _talkOnlyOnce:bool = true
## The dialogue tree ID of this InteractableNPC.
## Dialogue trees are located in "dialogue_trees."
## Internally, this is just a path to a folder within in "dialogue_trees,"
## so "_test" and "_test/basic/one" are both valid.
@export var dialogueTreeID:String = ""
## The dialogue tree node to load when the player first interacts with this InteractableNPC.
@export var initialDialogueID:String = ""
## Whether this [InteractableNPC] looks at the player while the dialogue event is happening.
@export var lookAtInteractorWhileTalking:bool = false
## If true, this [InteractableNPC] makes it so you cannot close the console.
@export var rejectConsoleExit:bool = false
## When [member rejectConsoleExit] is true, this will be the message
## that gets added to the console.
@export var rejectConsoleExitMessage:String = "[Console Closure Blocked]"

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Is true when this [InteractableNPC] is in a dialogue event.
var isTalking: bool = false
## Keeps track of if the player has interacted with this Interactable NPC.  If true, this NPC can no longer be talked to.
var wasTalkedTo: bool = false

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  The hitbox's collision shape.  Gets set when the node is ready.
var _hitboxShapes:Array[CollisionShape3D]
## [b]Internal-use only.[/b]  Keeps track of which dialogue object to reference at the moment.
var _currentDialogueID: String = ""
## [b]Internal-use only.[/b]  Tracks who is interacting with this NPC; curently can only be the player
var _currentInteractor:Node3D
## [b]Internal-use only.[/b]  Tracks whether the NPC should be patrolling.
## Mainly used to restore patrol state after finishing a dialogue interaction.
var _shouldPatrol:bool

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	# Makes sure the code after this is only ran in-game
	if Engine.is_editor_hint():
		return
	super()

	_shouldPatrol = patrolEnabled
	_currentDialogueID = initialDialogueID
	_hitboxShapes = _getHitboxShapes()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	super(delta)
	if lookAtInteractorWhileTalking and _currentInteractor and isTalking:
		lookAtPosition = _currentInteractor.global_position

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Enables the [InteractableNPC].  This will make it so the player can interact with this Interactable NPC.
func enable() -> void:
	_hitbox.monitorable = true
	for shape in _hitboxShapes:
		shape.set_deferred("disabled", false)
	super()

## Disables the [InteractableNPC].  This will make it so the player cannot interact with this Interactable NPC.
func disable() -> void:
	_hitbox.monitorable = false
	for shape in _hitboxShapes:
		shape.set_deferred("disabled", true)
	super()

## Resets the [InteractableNPC] to their default state.
## Currently only force-ends a dialogue event if they're in one
## and allows you to talk to them again.
func reset() -> void:
	if isTalking:
		_endDialogueConsole()
		#_endDialogueBox()
	_currentDialogueID = initialDialogueID
	wasTalkedTo = false
	super()

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Gets the [member hitbox]'s collision shapes.
func _getHitboxShapes() -> Array[CollisionShape3D]:
	var children:Array[Node] = _hitbox.get_children()
	var shapes:Array[CollisionShape3D] = []

	for child in children:
		if child is CollisionShape3D:
			shapes.push_back(child)
	return shapes

## [b]Internal-use only.[/b]  Loads the data of a dialogue object into [member _dialogueConsole].
## Make sure [member _currentDialogueID] is set to the dialogue you want to load before running.
func _loadDialogueConsoleData(dialogueEntry: Dictionary) -> void:
	var console:DialogueConsole = FR_WindowManager.dialogueConsole

	console.instigatingNpc = self
	console.currentDialogueID = _currentDialogueID
	console.mode = dialogueEntry.mode

	if dialogueEntry.mode == "hectic":
		console.hecticFailureDialogueID = dialogueEntry.nextOnHecticFailureID
		console.hecticDuration = dialogueEntry.hecticDuration
		console.delayBtwnWriteDialogueAndOptions = 0.25
	else:
		console.hecticFailureDialogueID = ""

	if dialogueEntry.textThemePreset != "":
		console.themeVariation.right = dialogueEntry.textThemePreset

	console.textWriteSpeed = dialogueEntry.writeSpeedCustom
	AudioLoader.loadSfxIntoPlayers(dialogueEntry.sfx, console.sfxPlayers)
	console.textToAdd = dialogueEntry.text
	console.loadOptionData(dialogueEntry.options)
	console.prepare()

## [b]Internal-use only.[/b]  Loads the next dialogue to display.
func _loadNextDialogueConsole(nextDialogueID: String) -> void:
	if nextDialogueID == "" and isTalking:
		_endDialogueConsole()
		return
	_currentDialogueID = nextDialogueID

	var dialogue:Dictionary = FR_Globals.getDialogueNode(dialogueTreeID, _currentDialogueID)
	_loadDialogueConsoleData(dialogue)
	FR_WindowManager.dialogueConsole.start()
	dialogue_advanced.emit()

## [b]Internal-use only.[/b]  Starts a dialogue event between itself and the player.
func _beginDialogueEventConsole(interactor:Player) -> void:
	isTalking = true
	patrolEnabled = false
	_currentInteractor = interactor
	if _currentInteractor:
		if _currentInteractor.has_method("disableInput"):
			_currentInteractor.disableInput(true)
		if _currentInteractor.has_method("freeze"):
			_currentInteractor.freeze(true)
	InputHandler.showCursor()
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	FR_WindowManager.createDialogueConsole()
	FR_WindowManager.subscribeToConsole(self)
	_loadNextDialogueConsole(initialDialogueID)

## [b]Internal-use only.[/b]  Ends the dialogue interaction.
func _endDialogueConsole() -> void:
	FR_WindowManager.killDialogueConsole()
	FR_WindowManager.unsubscribeToConsole(self)

	if _currentInteractor:
		if _currentInteractor.has_method("disableInput"):
			_currentInteractor.disableInput(false)
		if _currentInteractor.has_method("freeze"):
			_currentInteractor.freeze(false)
	InputHandler.hideCursor()

	isTalking = false
	_currentInteractor = null
	if _shouldPatrol:
		patrolEnabled = true
	if _talkOnlyOnce:
		wasTalkedTo = true

	finished_dialogue.emit()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles flow of what to do when this [InteractableNPC] is interacted with.
## Can also be used to simulate an interaction if need be.  The first paramter
## is the thing that interacted with this [InteractableNPC].
func _on_interaction(interactor:Node3D) -> void:
	if wasTalkedTo or isTalking:
		return

	#_beginDialogueEventBox(interactor)
	if interactor is Player:
		_beginDialogueEventConsole(interactor)

## [b]Internal-use only.[/b]  Handles logic for when a dialogue option is chosen.
func _on_console_option_chosen(nextID:String) -> void:
	if not isTalking:
		return

	_loadNextDialogueConsole(nextID)

## [b]Internal-use only.[/b]  Emits [signal option_available].
func _on_console_new_option_available() -> void:
	if not isTalking:
		return

	option_available.emit()

## [b]Internal-use only.[/b]  Emits [all_options_available].
func _on_console_all_options_available() -> void:
	if not isTalking:
		return

	all_options_available.emit()

## [b]Internal-use only.[/b]  Emits [dialogue_all_visible].
func _on_console_all_dialogue_text_visible() -> void:
	if not isTalking:
		return

	dialogue_all_visible.emit()

## [b]Internal-use only.[/b]  Emits [dialogue_all_visible].
func _on_console_close(_console:DialogueConsole) -> void:
	_endDialogueConsole()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []

	if not _hitbox:
		warnings.push_back("This NPC doesn't have a hitbox assigned yet. This is needed to allow the player to interact with them. A hitbox is an Area3D node.")
	elif _hitbox.collision_layer != 4:
		warnings.push_back("The hitbox's collision layer should only have square #3/Bit 2/the Interactable NPC layer enabled.")

	if initialDialogueID == "":
		warnings.push_back("The initial dialogue ID is not set.")

	#if not _dialogueBoxAnchor:
		#warnings.push_back("A marker for the dialogue box has not been set yet.")

	var inheritedWarnings:PackedStringArray = super()
	inheritedWarnings.append_array(warnings)

	return inheritedWarnings



















# //////////////////////////////////////////////////////////////////////////////
# //    DEPRECATED ZONE  DEPRECATED ZONE  DEPRECATED ZONE  DEPRECATED ZONE    //
# //////////////////////////////////////////////////////////////////////////////

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------
## @deprecated
## Attach methods for the [DialogueBox].
enum BoxAttachMethod {
	FOLLOW,  ## When spawned, the [DialogueBox] will be in the same relative position and rotation as this [InteractableNPC] all of the time.  If the [InteractableNPC] moves left, the DialogueBox will move left.  If the the [member _dialogueBoxAnchor] is right above the [InteractableNPC] and the [InteractableNPC] flips upside down, the [DialogueBox] will be physically below the [InteractableNPC] and upside down.
	STAY  ## When spawned, the [DialogueBox] will take the position and rotation of the [member _dialogueBoxAnchor] at that moment and stay there.  If the [InteractableNPC] moves or rotates after this moment, the [DialogueBox] will stay in place.
}

# ------------------------------------------------
# constants
# ------------------------------------------------
## @deprecated
## [b]Internal-use only.[/b]  A reference to the [DialogueBox] scene.
const _DIALOGUE_BOX_SCENE:Resource = preload(FR_Globals.SCENES.DialogueBox)

# ------------------------------------------------
# export variables
# ------------------------------------------------
@export_subgroup("Deprecated")
## @deprecated
## Tells the game where to spawn a [DialogueBox] when a player interacts with the Interactable NPC.
@export var _dialogueBoxAnchor:Marker3D
## @deprecated
## How the [DialogueBox] should act after beind spawned.
@export var _dialogueBoxAttachMethod:BoxAttachMethod

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## @deprecated
## [b]Internal-use only.[/b]  Holds a reference to this [InteractableNPC]'s dialogue box scene.
var _dialogueBox:DialogueBox = null
## @deprecated
## [b]Internal-use only.[/b]  Single-use boolean to determine if the dialogue box's signals have been connected to functions yet.
var _connectedDialogueBoxSignals:bool = false

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## @deprecated
## [b]Internal-use only.[/b]  Creates a [DialogueBox]. Only one can exist at a time.
func _spawnDialogueBox() -> void:
	if _dialogueBox != null:
		return

	_dialogueBox = _DIALOGUE_BOX_SCENE.instantiate()
	if(_dialogueBoxAttachMethod == BoxAttachMethod.FOLLOW):
		_dialogueBoxAnchor.add_child(_dialogueBox)
		# undo the scaling being inherited from this InteractableNPC
		_dialogueBox.scale += Vector3.ONE - scale

	elif(_dialogueBoxAttachMethod == BoxAttachMethod.STAY):
		get_parent().add_child(_dialogueBox)
		_dialogueBox.global_position = _dialogueBoxAnchor.global_position
		_dialogueBox.global_rotation = _dialogueBoxAnchor.global_rotation

## @deprecated
## [b]Internal-use only.[/b]  Connects the [member _dialogueBox] signals to functions.
## Only needs to be ran once.
func _connectDialogueBoxSignals() -> void:
	if _connectedDialogueBoxSignals:
		return
	_connectedDialogueBoxSignals = true

	_dialogueBox.update_me.connect(_loadNextDialogueBox)
	_dialogueBox.new_option_available.connect(_on_console_option_chosen)
	_dialogueBox.all_options_available.connect(_on_console_all_options_available)
	_dialogueBox.all_dialogue_text_visible.connect(_on_console_all_dialogue_text_visible)

## @deprecated
## [b]Internal-use only.[/b]  Disconnects the [member _dialogueBox] signals to functions.
func _disconnectDialogueBoxSignals() -> void:
	if not _connectedDialogueBoxSignals:
		return
	_connectedDialogueBoxSignals = false

	_dialogueBox.update_me.disconnect(_loadNextDialogueBox)
	_dialogueBox.new_option_available.disconnect(_on_console_option_chosen)
	_dialogueBox.all_options_available.disconnect(_on_console_all_options_available)
	_dialogueBox.all_dialogue_text_visible.disconnect(_on_console_all_dialogue_text_visible)

## @deprecated
## [b]Internal-use only.[/b]  Loads the data of a dialogue object into [member _dialogueBox].
## Make sure [member _currentDialogueID] is set to the dialogue you want to load before running.
func _loadDialogueBoxData(dialogueEntry:Dictionary) -> void:
	_dialogueBox.realOwner = self
	_dialogueBox.currentDialogueID = _currentDialogueID
	_dialogueBox.mode = dialogueEntry.mode
	if dialogueEntry.mode == "hectic":
		_dialogueBox.hecticFailureDialogueID = dialogueEntry.nextOnHecticFailureID
	else:
		_dialogueBox.hecticFailureDialogueID = ""
	_dialogueBox.text = dialogueEntry.text
	_dialogueBox.textWriteSpeed = dialogueEntry.writeSpeedCustom
	_dialogueBox.loadSfx(dialogueEntry.sfx)
	_dialogueBox.loadOptionData(dialogueEntry.options)
	_dialogueBox.prepare()

## @deprecated
## [b]Internal-use only.[/b]  Loads the next dialogue to display.
func _loadNextDialogueBox(nextDialogueID: String) -> void:
	#print("\nloading dialogue: [", nextDialogueID, "]")
	if nextDialogueID == "" and isTalking:
		_endDialogueBox()
		return

	_currentDialogueID = nextDialogueID

	var dialogue:Dictionary = FR_Globals.getDialogueNode(dialogueTreeID, _currentDialogueID)
	#print("dialogue data: ", dialogue)
	_loadDialogueBoxData(dialogue)
	_dialogueBox.start()
	dialogue_advanced.emit()

## @deprecated
## [b]Internal-use only.[/b]  Starts a dialogue event between itself and the interactor.
func _beginDialogueEventBox(interactor:Node3D) -> void:
	# rotate to face player immediately to properly spawn dialogue box
	# is a hacky work around to spawn the [DialogueBox] in the correct position.
	var currentRotation:Vector3 = rotation
	if lookAtInteractorWhileTalking and interactor:
		look_at(Vector3(
			interactor.global_position.x,
			global_position.y,
			interactor.global_position.z
		))
		lookAtPosition = interactor.global_position

	isTalking = true
	patrolEnabled = false
	_currentInteractor = interactor

	_spawnDialogueBox()
	_connectDialogueBoxSignals()
	_loadNextDialogueBox(initialDialogueID)

	# restore rotation from before hacky work around
	rotation = currentRotation

## @deprecated
## [b]Internal-use only.[/b]  Ends the dialogue interaction.
func _endDialogueBox() -> void:
	_disconnectDialogueBoxSignals()
	if _dialogueBox != null:
		_dialogueBox.kill()
		_dialogueBox = null

	isTalking = false
	_currentInteractor = null
	if _shouldPatrol:
		patrolEnabled = true
	if _talkOnlyOnce:
		wasTalkedTo = true

	finished_dialogue.emit()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
