@tool
extends DialogueWindow
class_name DialogueConsoleOptionWindow
## A dialogue option window that spawns when a user is able to continue a dialogue event.
##
## Spawned by [DialogueConsole] via [WindowManager].
## [br][br]
## All aspects are configured by [DialogueConsole] when it spawns one of these windows.
##
## [b]SFX Events:[/b][br]
## While there are additional SFX events for this, they are configured by [DialogueConsole]
## when it spawns one of these.
##
##
## [br][br][br]
## [b]Styling:[/b][br]
## It uses the [DialogueWindow] theme settings.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when this option is chosen.
signal option_selected(myself:DialogueConsoleOptionWindow)
## Emitted when this option window enables itself.
## [param dataIndex] is the index in [member DialogueConsole._optionData]
## of the data used to create this window.
signal enabled(dataIndex:int)
## Emitted when this option window disables itself.
## [param dataIndex] is the index in [member DialogueConsole._optionData]
## of the data used to create this window.
signal disabled(dataIndex:int)

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
## The label that denotes which "index" is associated with this option.
@onready var contentsLabel:RichTextLabel = %ContentsLabel
## The timer representing the lifetime of this window.
@onready var lifetimeTimer:Timer = %LifetimeTimer
## The SFX event players that are manually set outside of [SfxEventHandler].
## [br]
## Currently, it has [param spawn] and [param text], which are customized by [DialogueConsole]
## when it spawns this window.
@onready var sfxPlayers:Dictionary[String, AudioStreamPlayer] = {
	"spawn": %sfxSpawn,
	"text": %sfxText
}

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The option ID this option window corresponds to.
## [br][br]
## Comes with a setter so you can treat it like a normal variable
## while updating the relevant stuff.
var id:int:
	set(newID):
		id = newID
		_updateLabel()

## The option text of the option this option window corresponds to.
## [br][br]
## Comes with a setter so you can treat it like a normal variable
## while updating the relevant stuff.
var text:String:
	set(newText):
		text = newText
		_updateLabel()

## The text theme variation for this option.
## [br][br]
## Comes with a setter that automatically updates the theme variation on the labels.
var themeVariation:String:
	set(value):
		themeVariation = value
		contentsLabel.theme_type_variation = value

## How long to wait after [DialogueConsole] starts spawning DialogueConsoleOptionWindows
## before this actually enables itself.
var spawnDelay:float = 0.0
## How long this option lives before disabling itself.
var lifetime:float = 0.0
## If this option is disabled or not.
var isDisabled:bool = false:
	set(newState):
		isDisabled = newState
		visible = !newState
		if newState:
			disabled.emit(id)
		else:
			enabled.emit(id)

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	super()
	windowType = "console_option"

func _process(_delta: float) -> void:
	super(_delta)
	if Engine.is_editor_hint():
		return

func _gui_input(event: InputEvent) -> void:
	super(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Starts displaying the the loaded text in [member textToAdd].
func start() -> void:
	sfxPlayers.spawn.play()

	if spawnDelay > 0.0:
		isDisabled = true
		await get_tree().create_timer(spawnDelay).timeout
		isDisabled = false

	if lifetime > 0:
		lifetimeTimer.wait_time = lifetime
		lifetimeTimer.start()

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Updates the contents label.
func _updateLabel() -> void:
	contentsLabel.text = "[" + str(id) + "] " + text

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Handles logic for when this window is clicked.
func _on_pressed() -> void:
	if not _dragging:
		#print("option selected via button")
		option_selected.emit(self)

## [b]Internal-use only.[/b]
## Handles logic for when this window's lifespan runs out.
func _on_lifetime_timer_timeout() -> void:
	isDisabled = true

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
## [b]Editor-use Only.[/b]
## Returns editor warnings depending on this thing's state.
func _get_configuration_warnings() -> PackedStringArray:
	return super()

## [b]Editor-use Only.[/b]
## Hides certain export fields depending on this thing's state.
func _validate_property(property: Dictionary) -> void:
	super(property)
