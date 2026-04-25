extends DC_BaseNode
class_name DC_OptionNode
## The node in [DialogueCreator] that represents an option in a dialogue object file that wills be used in-game.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted whenever a field gets updated.
signal values_updated(port:int, newValues:Dictionary)
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
## The text field you can edit.
@onready var textField:TextEdit = %TextField
## The node that handles the type you can choose.
@onready var typeField:DC_TypeFieldOption = %TypeField
## The node that handles the write speed aspects you can modify.
@onready var writeSpeedAspectsHandler:DC_AspectsWriteSpeed = %WriteSpeedAspects
## The node that handles the SFX event SFX IDs you can choose.
@onready var sfxEventAspectsHandler:DC_AspectsSfx = %SfxAspects
## The spawn delay field you can set.
@onready var spawnDelayField:SpinBox = %SpawnDelayField
## The lifetime field you can set.
@onready var lifetimeField:SpinBox = %LifetimeField
## The node that handles all [StoryFlags] to set when this option is picked.
@onready var setFlagsAspectsHandler:DC_AspectsSetFlags = %SetFlags
## The node that handles all [StoryFlags] to check wheen loading this option.
@onready var checkFlagsAspectsHandler:DC_AspectsCheckFlags = %CheckFlags

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The option port of the [DC_DiaalogueNode] this is connected to.
var port:int = -1

## Used to get and set the text for this [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the current text
## print(optionNode.text)  # output: "hi"
## 
## # Set the textx
## optionNode.text = "hi there"
## [/codeblock]
var text:String:
	set(value):
		if not textUpdateFromField:
			textField.text = value
			textUpdateFromField = true
		_on_attribute_modified()
	get():
		return textField.text
## Whether the update the text in the text field with a new value or not.
var textUpdateFromField:bool = true

## Used to get and set the type for this [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## Valid types can be found in [member DialogueDefaults.OPTION_TYPES].
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the current type
## print(optionNode.type)  # output: "neutral"
## 
## # Set the type
## optionNode.type = "positive"
## [/codeblock]
var type:String:
	set(newType):
		typeField.option = newType
		_on_attribute_modified()
	get():
		return typeField.option

## Used to get and set the SFX IDs for each SFX event this [DC_OptionNode] has.
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## Valid SFX IDs can be found in "res://sounds/sfx/".  The IDs will be the names of all folders found there.
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the currently set SFX events
## print(optionNode.sfxEventAspects)  # output: {"eventId1": "sfxId1", "eventId2": "sfxId2"}
## 
## # Set the SFX IDs for some SFX events
## optionNode.sfxEventAspects = {
## 	"eventId1": "sfxId1",
## 	"eventId2": "sfxId2"
## }
## [/codeblock]
var sfxEventAspects:Dictionary:
	set(newSfxEventAspects):
		sfxEventAspectsHandler.aspects = newSfxEventAspects
		_on_attribute_modified()
	get():
		return sfxEventAspectsHandler.aspects

## Used to get and set the write speed preset for this [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## Valid types can be found in [member DialogueDefaults.WRITE_SPEED_PRESETS]'s keys.
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the current write speed preset
## print(optionNode.writeSpeedPreset)  # output: "medium"
## 
## # Set the write speed preset
## optionNode.writeSpeedPreset = "fast"
## [/codeblock]
var writeSpeedPreset:String:
	set(newPreset):
		writeSpeedAspectsHandler.preset = newPreset
		_on_attribute_modified()
	get():
		return writeSpeedAspectsHandler.preset

## Used to get and set the write speed value for this [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the current write speed
## print(optionNode.writeSpeedValue)  # output: 60
## 
## # Set the write speed
## optionNode.writeSpeedValue = 45
## [/codeblock]
var writeSpeedValue:float:
	set(newSpeed):
		writeSpeedAspectsHandler.value = newSpeed
		_on_attribute_modified()
	get():
		return writeSpeedAspectsHandler.value

## Used to get and set the spawn delay for this [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the current spawn delay
## print(optionNode.spawnDelay)  # output: 3.0
## 
## # Set the spawn delay
## optionNode.spawnDelay = 1.0
## [/codeblock]
var spawnDelay:float:
	set(newDelay):
		spawnDelayField.value = newDelay
		_on_attribute_modified()
	get():
		return spawnDelayField.value

## Used to get and set the lifetime for this [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the current lifetime
## print(optionNode.lifetime)  # output: 3.0
## 
## # Set the lifetime
## optionNode.lifetime = 1.0
## [/codeblock]
var lifetime:float:
	set(newLife):
		lifetimeField.value = newLife
		_on_attribute_modified()
	get():
		return lifetimeField.value

## Used to get and set the [StoryFlags] to set for this [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the flags that will be set and their new value when this option is picked
## print(optionNode.setFlags)  # {"testFlag": false}
## 
## # Set the flags that will be set and their new value when this option is picked
## optionNode.setFlags = {"testFlag": true}
## [/codeblock]
var setFlags:Dictionary:
	set(newFlags):
		setFlagsAspectsHandler.currentFlags = newFlags
	get():
		return setFlagsAspectsHandler.currentFlags

## Used to get and set the [StoryFlags] to check the value of for this [DC_OptionNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var optionNode:DC_OptionNode = # a pre-configured node from the scene tree
##
## # Get the flags that will be checked and the value to check against when this option is picked
## print(optionNode.checkFlags)  # {"testFlag": false}
## 
## # Set the flags that will checked and the value to check against when this option is picked
## optionNode.checkFlags = {"testFlag": true}
## [/codeblock]
var checkFlags:Dictionary:
	set(newFlags):
		checkFlagsAspectsHandler.currentFlags = newFlags
	get():
		return checkFlagsAspectsHandler.currentFlags

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
	
	sfxEventAspects = DialogueDefaults.DEFAULT_OPTION.sfx
	spawnDelay = DialogueDefaults.DEFAULT_OPTION.spawnDelay
	lifetime = DialogueDefaults.DEFAULT_OPTION.lifetime

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
		"text": textField.text
	}
	
	# text theme (unused atm)
	
	currentValues.type = type
	
	if writeSpeedPreset != DialogueDefaults.DEFAULT_DIALOGUE.writeSpeed:
		currentValues.writeSpeed = writeSpeedPreset
		if currentValues.writeSpeed == "custom":
			currentValues.writeSpeedCustom = writeSpeedAspectsHandler.value
	
	if sfxEventAspects != {}:
		currentValues.sfx = sfxEventAspects
	
	# background theme (unused atm)
	# particles (unused atm)
	
	if spawnDelay != DialogueDefaults.DEFAULT_OPTION.spawnDelay:
		currentValues.spawnDelay = spawnDelay
	
	if lifetime != DialogueDefaults.DEFAULT_OPTION.lifetime:
		currentValues.lifetime = lifetime
	
	if nextID != "":
		currentValues.nextID = nextID
	
	if setFlags != {}:
		currentValues.setFlags = setFlags
	
	if checkFlags != {}:
		currentValues.checkFlags = checkFlags

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
func _on_attribute_modified() -> void:
	#print("option modified, emitting")
	values_updated.emit(port, _getFields())

## [b]Internal-use only.[/b]  Handles logic for when an attribute gets modified.
func _on_attribute_modified_parameter(_ignore_me) -> void:
	_on_attribute_modified()

## [b]Internal-use only.[/b]  Handles logic for when the [member textField] gets updated.
func _on_text_field_updated() -> void:
	textUpdateFromField = true
	_on_attribute_modified()

## [b]Internal-use only.[/b]  Handles logic for when the next [DC_DialogueNode]'s
## ID gets updatedd.
func _on_next_object_id_modified(newID:String) -> void:
	nextID = newID
	_on_attribute_modified()

## [b]Internal-use only.[/b]  Handles logic for when the debug button gets pressed.
func _on_debug_pressed() -> void:
	print("------ Dialogue Option ------")
	print("Port: ", port)
	print("Text: ", text)
	print("Type: ", typeField.option)
	
	if writeSpeedAspectsHandler.preset != DialogueDefaults.DEFAULT_DIALOGUE.writeSpeed:
		print("Write Speed Preset: ", writeSpeedAspectsHandler.preset)
		print("Write Speed Value: ", writeSpeedAspectsHandler.value)
	
	var aspects:Dictionary = sfxEventAspects
	if aspects != {}:
		print("sfxAspects:")
		for event in aspects:
			print("\t", event, ": ", aspects[event])
	
	print("spawnDelay: ", spawnDelay)
	print("lifetime: ", lifetime)

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

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_close_button_pressed() -> void:
	super()

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_resize_height() -> void:
	super()

## [b]Internal-use only.[/b]  Only here to see what signals are connected to the function.
func _on_toggle_visibility(isVisible:bool) -> void:
	super(isVisible)

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
