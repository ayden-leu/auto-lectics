extends DC_BaseNode
class_name DC_OptionNode
## The node in [DialogueCreator] that represents an option in a dialogue object file that wills be used in-game.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted whenever a field gets updated.
signal values_updated(port:int, me:DC_OptionNode)
## Emitted when this is planning on being deleted.  Listen to this if you are connected to the dialogue port.
signal disconnect_dialogue(port:int)

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## The port number of the incoming option port
const OPTION_PORT:int = 0
## The port number of the outgoing next dialogue ID port.
const NEXT_ID_PORT:int = 0

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The node that handles the text field you can edit.
@onready var textField:DC_BaseNodeTextField = %TextField
## The node that handles the type you can choose.
@onready var typeField:DC_BaseNodeField = %TypeChooser
## The node that handles the spawn delay field you can set.
@onready var spawnDelayField:DC_BaseNodeNumber = %SpawnDelayField
## The node that handles the lifetime field you can set.
@onready var lifetimeField:DC_BaseNodeNumber = %LifetimeField
## The node that handles the text themes you can choose.
@onready var textThemeField:DC_BaseNodeChooser = %TextThemeChooser
## The node that handles the text writee speed preset you can choose.
@onready var writeSpeedPresetField:DC_BaseNodeChooser = %WriteSpeedPresetChooser
## The node that handles the text write speed value you can set.
@onready var writeSpeedValueField:DC_BaseNodeField = %WriteSpeedValueField
## The node that handles the SFX event SFX IDs you can choose.
@onready var sfxEventAspectsHandler:DC_BaseNodeField = %SfxAspects
## The node that handles all [StoryFlags] to set when this option is picked.
@onready var setFlagsAspectsHandler:DC_SetFlagAspects = %SetFlags
## The node that handles all [StoryFlags] to check wheen loading this option.
@onready var checkFlagsAspectsHandler:DC_CheckFlagAspects = %CheckFlags
## The node that handles the disableBack state you can toggle.
@onready var disableBackToggler:DC_SectionToggle = %DisableBackToggler
## The node that handles the reject back message you can edit.
@onready var rejectBackMessageField: DC_BaseNodeTextField = %RejectBackMessageField


# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The option port of the [DC_DialogueNode] this is connected to.
var port:int = -1

## The text for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var text:String:
	set(newText):
		textField.text = newText
	get():
		return textField.text

## The type for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var type:String:
	set(newType):
		typeField.chosen = newType
	get():
		return typeField.chosen

## The spawn delay for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var spawnDelay:float:
	set(newDelay):
		spawnDelayField.value = newDelay
	get():
		return spawnDelayField.value

## The lifetime for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var lifetime:float:
	set(newLife):
		lifetimeField.value = newLife
	get():
		return lifetimeField.value

## The text theme preset for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var textThemePreset:String:
	set(newTheme):
		textThemeField.chosen = newTheme
	get():
		return textThemeField.chosen

## The teext write speed preset for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var writeSpeedPreset:String:
	set(newPreset):
		writeSpeedPresetField.chosen = newPreset
		_on_field_updated()
	get():
		return writeSpeedPresetField.chosen

## The teext write speed value for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var writeSpeedValue:float:
	set(newSpeed):
		writeSpeedValueField.value = newSpeed
		_on_field_updated()
	get():
		return writeSpeedValueField.value

## The configured SFX events for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var sfxEventAspects:Dictionary:
	set(newSfxEventAspects):
		sfxEventAspectsHandler.configuredEvents = newSfxEventAspects
		_on_field_updated()
	get():
		return sfxEventAspectsHandler.configuredEvents

## The StoryFlags that are set when this [DC_OptionNode] is chosen.
## Setting this will update other nodes appropriately.
## [br][br]
## Dictionary format is the following:
## [codeblock]
## var dict:Dictionary = {
## 	"flagName": true  # or false
## }
## [/codeblock]
var setFlags:Dictionary:
	set(newFlags):
		setFlagsAspectsHandler.currentFlags = newFlags
	get():
		return setFlagsAspectsHandler.currentFlags

## The StoryFlags that are checked against when trying to spawn this [DC_OptionNode].
## Setting this will update other nodes appropriately.
## [br][br]
## Dictionary format is the following:
## [codeblock]
## var dict:Dictionary = {
## 	"flagName": true  # or false
## }
## [/codeblock]
var checkFlags:Dictionary:
	set(newFlags):
		checkFlagsAspectsHandler.currentFlags = newFlags
	get():
		return checkFlagsAspectsHandler.currentFlags

## The configured "disableBack" state for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var disableBack:bool:
	set(newState):
		disableBackToggler.button_pressed = newState
	get():
		return disableBackToggler.button_pressed

## The back command rejection message for this [DC_OptionNode].
## Setting this will update other nodes appropriately.
var rejectBackMessage:String:
	set(newText):
		rejectBackMessageField.text = newText
	get():
		return rejectBackMessageField.text

## The [member DC_DialogueNode.id] to load when a player chooses this option.
var nextID:String = ""

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	super()
	set_slot_color_left(0, PortColor.OPTION)
	set_slot_type_left(0, PortType.OPTION)

	set_slot_color_right(1, PortColor.DIALOGUE)
	set_slot_type_right(1, PortType.DIALOGUE)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Sets [member port] to be "empty" sets [member nextID] to be an empty string.
func dialogueDisconnected() -> void:
	port = -1
	nextID = ""

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## Returns the currently configured fields for thie [DC_OptionNode].
## If a field matches its corresponding field in [member DialogueDefaults.DEFAULT_OPTION],
## it is not included in the return payload.
func _getFields() -> Dictionary:
	if not textField:
		return {"error": "textField not loaded"}

	var currentValues:Dictionary = {
		"text": text
	}

	if type != _CHECK_NPC_DEFAULT_VALUE:
		currentValues.type = type

	if textThemePreset != _CHECK_NPC_DEFAULT_VALUE:
		currentValues.textThemePreset = textThemePreset

	if writeSpeedPreset != _CHECK_NPC_DEFAULT_VALUE:
		currentValues.writeSpeed = writeSpeedPreset
		if currentValues.writeSpeed == "custom":
			currentValues.writeSpeedCustom = writeSpeedValue

	if sfxEventAspects != {}:
		currentValues.sfx = sfxEventAspects

	if spawnDelay > _CHECK_NPC_DEFAULT_VALUE_NUM:
		currentValues.spawnDelay = spawnDelay

	if lifetime > _CHECK_NPC_DEFAULT_VALUE_NUM:
		currentValues.lifetime = lifetime

	if nextID != "":
		currentValues.nextID = nextID

	if setFlags != {}:
		currentValues.setFlags = setFlags

	if checkFlags != {}:
		currentValues.checkFlags = checkFlags

	if disableBack:
		currentValues.allowBack = !disableBack
		if rejectBackMessage != "":
			currentValues.rejectBackMessage = rejectBackMessage

	return currentValues

## Disconnects any connected [DC_DialogueNode]s, then prepares for deletion.
func _delete() -> void:
	disconnect_dialogue.emit(port)
	super()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when the connected [DC_DialogueNode]
## gets disconneected
func _on_dialogue_node_disconnected() -> void:
	dialogueDisconnected()

## [b]Internal-use only.[/b]  Handles logic for when an attribute gets modified.
func _on_field_updated() -> void:
	print("option modified, emitting")
	var data:Dictionary = _getFields()
	print(data)
	print()
	values_updated.emit(port, self)

func _on_field_updated_state(_newState:bool) -> void:
	_on_field_updated()

## [b]Internal-use only.[/b]  Handles logic for when an attribute gets modified.
func _on_attribute_modified_parameter(_ignore_me) -> void:
	_on_field_updated()

## [b]Internal-use only.[/b]  Handles logic for when the [member textField] gets updated.
func _on_text_field_updated() -> void:
	#textUpdateFromField = true
	_on_field_updated()

## [b]Internal-use only.[/b]  Handles logic for when the next [DC_DialogueNode]'s
## ID gets updatedd.
func _on_next_object_id_modified(newID:String) -> void:
	nextID = newID
	_on_field_updated()

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_close_button_pressed() -> void:
	super()

## [b]Internal-use only.[/b]
## Only here to see what signals are connected to the function.
func _on_resize_height() -> void:
	super()

## [b]Internal-use only.[/b]
## Only here to see what signals are connected to the function.
func _on_toggle_visibility(isVisible:bool) -> void:
	super(isVisible)

## [b]Internal-use only.[/b]  Handles logic for when the debug button gets pressed.
func _on_debug_pressed() -> void:
	print("------ Dialogue Option ------")
	print("Port: ", port)
	print("Text: ", text)
	print("Type: ", type)

	if spawnDelay >= 0:
		print("spawnDelay: ", spawnDelay)

	if lifetime >= 0:
		print("lifetime: ", lifetime)

	if textThemePreset != _CHECK_NPC_DEFAULT_VALUE:
		print("Text Theme: ", textThemePreset)

	if writeSpeedPreset != _CHECK_NPC_DEFAULT_VALUE:
		print("Write Speed Preset: ", writeSpeedPreset)
		print("Write Speed Value: ", writeSpeedValue)

	var aspects:Dictionary = sfxEventAspects
	if aspects != {}:
		print("sfxAspects:")
		for event in aspects:
			print("\t", event, ": ", aspects[event])


	var currentSetFlags:Dictionary = setFlags
	if currentSetFlags != {}:
		print("setFlags:")
		for flagID in currentSetFlags.keys():
			print("\t", flagID, ": ", currentSetFlags[flagID])

	var currentCheckFlags:Dictionary = checkFlags
	if currentCheckFlags != {}:
		print("checkFlags:")
		for flagID in currentCheckFlags.keys():
			print("\t", flagID, ": ", currentCheckFlags[flagID])

	print("nextID: ", nextID)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
