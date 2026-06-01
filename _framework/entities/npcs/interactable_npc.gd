@tool
@icon("uid://b105kdcrwpi0r")
extends NPC
class_name InteractableNPC
## The base class of all Interactable NPCs in the game.
##
## Inherits all features from [NPC].
## [br][br]
## Interactable NPCs allow the player to interact with them and initiate a dialogue event.
##
##
##
## [br][br][br]
## [b]Configuration:[/b][br]
## [member _hitbox] allows players to interact with this InteractableNPC.
## [br][br]
## If [member _talkOnlyOnce] is [code]true[/code], then the player will only be able to talk to this
## InteractableNPC once.  If you want to let the player talk to this InteractableNPC
## again, you have to run [method reset] at some point.
## [LoopManager] does this whenever it resets.
## [br][br]
## [member dialogueTreeID] is the name of the subfolder to look into when loading
## dialogue nodes, [member initialDialogueID] is the dialogue node to load
## into [DialogueConsole] when the player interacts with this, and [member _currentDialogueID]
## is the ID of the currently loadeed dialogue node.
## [br][br]
## If [member lookAtInteractorWhileTalking] is [code]true[/code], this InteractableNPC
## will look at [member _currentInteractor] while it performs the dialogue event.
## [br][br]
## [member rejectConsoleExit] will make it so the player cannot close the [DialogueConsole],
## and [member rejectConsoleExitMessage] is the message that is displayed in the [DialogueConsole]
## when the player tries closing it.
##
##
## [br][br][br]
## [b]Interaction:[/b][br]
## Upon being interacted with, the following functions are ran, assuming its a valid interactor:
## [br][br]
## - [method _beginDialogueEventConsole]
## [br][br]
## - [method _loadNextDialogueConsole]
## [br][br]
## - [method DialogueLoader.getDialogueNode]
## [br][br]
## - [method _loadDialogueConsoleData]
## [br][br]
## - [method DialogueConsole.prepare] via reference obtained by [WindowManager]
## [br][br]
## - [method DialogueConsole.start] via [WindowManager]
##
##
## [br][br][br]
## [b]Other notes:[/b][br]
## [member isTalking] and [member wasTalkedTo] can be helpful if you want to know
## the state of this InteractableNPC.
## [br][br]
## This InteractableNPC will remember if it should be patrolling or not while
## performing a dialogue event.  It is stored in [member _shouldPatrol].

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
var isTalking:bool = false
## Keeps track of if the player has interacted with this Interactable NPC.  If true, this NPC can no longer be talked to.
var wasTalkedTo:bool = false

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  The hitbox's collision shape.  Gets set when the node is ready.
var _hitboxShapes:Array[CollisionShape3D]
## [b]Internal-use only.[/b]  Keeps track of which dialogue object to reference at the moment.
var _currentDialogueID:String = ""
## [b]Internal-use only.[/b]  Tracks who is interacting with this NPC; curently can only be the player
var _currentInteractor:Node3D
## [b]Internal-use only.[/b]  Tracks whether the NPC should be patrolling.
## Mainly used to restore patrol state after finishing a dialogue interaction.
var _shouldPatrol:bool

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()

	_shouldPatrol = patrolEnabled
	_currentDialogueID = initialDialogueID
	_hitboxShapes = _getHitboxShapes()

func _process(delta:float) -> void:
	if Engine.is_editor_hint():
		return

	super(delta)
	if lookAtInteractorWhileTalking and _currentInteractor and isTalking:
		lookAtPosition = _currentInteractor.global_position

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Enables the [InteractableNPC].
## This will make it so the player can interact with this InteractableNPC.
func enable() -> void:
	_hitbox.monitorable = true
	for shape in _hitboxShapes:
		shape.set_deferred("disabled", false)
	super()

## Disables the [InteractableNPC].
## This will make it so the player cannot interact with this InteractableNPC.
func disable() -> void:
	_hitbox.set_deferred("monitorable", false)
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
## [b]Internal-use only.[/b]
## Gets the [member hitbox]'s collision shapes.
func _getHitboxShapes() -> Array[CollisionShape3D]:
	var children:Array[Node] = _hitbox.get_children()
	var shapes:Array[CollisionShape3D] = []

	for child in children:
		if child is CollisionShape3D:
			shapes.push_back(child)
	return shapes

## [b]Internal-use only.[/b]
## Loads the data of a dialogue object into [member _dialogueConsole].
## Make sure [member _currentDialogueID] is set to the dialogue you want to load before running.
func _loadDialogueConsoleData(dialogueEntry:Dictionary) -> void:
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

## [b]Internal-use only.[/b]
## Loads the next dialogue to display.
func _loadNextDialogueConsole(nextDialogueID:String) -> void:
	if nextDialogueID == "" and isTalking:
		_endDialogueConsole()
		return
	_currentDialogueID = nextDialogueID

	var dialogue:Dictionary = DialogueLoader.getDialogueNode(dialogueTreeID, _currentDialogueID)
	_loadDialogueConsoleData(dialogue)
	FR_WindowManager.dialogueConsole.start()
	dialogue_advanced.emit()

## [b]Internal-use only.[/b]
## Starts a dialogue event between itself and the player.
func _beginDialogueEventConsole(interactor:Player) -> void:
	isTalking = true
	patrolEnabled = false
	_currentInteractor = interactor
	# moved logic to WindowManager.createDialogueConsole()
	# since there is only one interactor at the moment:  the Player
	#if _currentInteractor:
		#if _currentInteractor.has_method("disableInput"):
			#_currentInteractor.disableInput(true)
		#if _currentInteractor.has_method("freeze"):
			#_currentInteractor.freeze(true)

	FR_WindowManager.createDialogueConsole()
	FR_WindowManager.subscribeToConsole(self)
	_loadNextDialogueConsole(initialDialogueID)

## [b]Internal-use only.[/b]
## Ends the dialogue interaction.
func _endDialogueConsole() -> void:
	FR_WindowManager.killDialogueConsole()
	FR_WindowManager.unsubscribeToConsole(self)

	# moved logic to WindowManager.createDialogueConsole()
	# since there is only one interactor at the moment:  the Player
	#if _currentInteractor:
		#if _currentInteractor.has_method("disableInput"):
			#_currentInteractor.disableInput(false)
		#if _currentInteractor.has_method("freeze"):
			#_currentInteractor.freeze(false)
	#FR_WindowManager.updateCursorStateForWindows()

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
## [b]Internal-use only.[/b]
## Handles flow of what to do when this [InteractableNPC] is interacted with.
## Can also be used to simulate an interaction if need be.
## [param interactor] is the thing that interacted with this [InteractableNPC].
func _on_interaction(interactor:Node3D) -> void:
	if wasTalkedTo or isTalking:
		return

	if interactor is Player:
		_beginDialogueEventConsole(interactor)

## [b]Internal-use only.[/b]
## Handles logic for when a dialogue option is chosen.
func _on_console_option_chosen(nextID:String) -> void:
	if not isTalking:
		return

	_loadNextDialogueConsole(nextID)

## [b]Internal-use only.[/b]
## Emits [signal option_available].
func _on_console_new_option_available() -> void:
	if not isTalking:
		return

	option_available.emit()

## [b]Internal-use only.[/b]
## Emits [all_options_available].
func _on_console_all_options_available() -> void:
	if not isTalking:
		return

	all_options_available.emit()

## [b]Internal-use only.[/b]
## Emits [dialogue_all_visible].
func _on_console_all_dialogue_text_visible() -> void:
	if not isTalking:
		return

	dialogue_all_visible.emit()

## [b]Internal-use only.[/b]
## Handles logic for when the [DialogueConsole] wants to be closed.
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
