extends DC_BaseNode
class_name DC_DialogueNode
## The node in [DialogueCreator] that represents a dialogue object file to be used in-game.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the value of [member id] gets updated.
signal id_updated(newID:String)
## Emitted when this is planning on being deleted. Listen to this if you rely on the value of [member id].
signal disconnect_id()
## Emitted when this wants to remove an option port, and that option port has a connection.
signal disconnect_option(myName:String, port:int)
## Emitted when this is planning on being deleted. Listen to this if you are connected to an option port.
signal disconnect_all_options
## Emitted when this wants to save itself to a file.
signal save_me(data:Dictionary)
## Emitted when an existing connection to the "Next On Hectic Fail" port needs to be disconnected.
signal disconnect_hectic_port(myName:String, port:int)
## Emitted when a previously existing connection to the "Next On Hectic Fail" port needs to be reconnected.
signal reconnect_hectic_port(connection:Dictionary)
## [b]Internal-use only.[/b]  Emitted when the number of options increases or decreases.
signal _option_amount_changed()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]  The scene for the label next to each option port.
const _OPTION_LABEL_SCENE:PackedScene = preload("uid://cjuc58ngbb0lm")
## [b]Internal-use only.[/b]  The number of nodes above the option port section.
const _NUM_NODES_ABOVE_OPTIONS:int = 3
## The port number of the incoming dialogue ID port.
const DIALOGUE_ID_PORT:int = 0

# ------------------------------------------------
# export variables
# ------------------------------------------------
## The ID field you can edit.
@onready var dialogueIDField:LineEdit = %DialogueIDField
## The text field you can edit.
@onready var textField:TextEdit = %TextField
## The node that handles the type you can choose.
@onready var typeField:DC_TypeFieldOption = %TypeField
## The node that handles the mode you can choose.
@onready var modeField:DC_ModeFieldOption = %ModeField
## The node that handles the write speed aspects you can modify.
@onready var writeSpeedAspectsHandler:DC_AspectsWriteSpeed = %WriteSpeedAspects
## The node that handles the SFX event SFX IDs you can choose.
@onready var sfxEventAspectsHandler:DC_AspectsSfx = %SfxAspects

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## Used to get and set the ID for this [DC_DialogueNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var dialogueNode:DC_DialogueNode = # a pre-configured node from the scene tree
##
## # Get the current ID
## print(dialogueNode.id)  # output: "someID"
## 
## # Set the ID
## dialogueNode.id = "someOtherID"
## [/codeblock]
var id:String:
	set(value):
		if not idUpdateFromField:
			dialogueIDField.text = value
			idUpdateFromField = true
		title = "Dialogue: " + value
		id_updated.emit(value)
	get():
		return dialogueIDField.text
## Whether the update the text in the ID field with a new value or not.
var idUpdateFromField:bool = true

## Used to get and set the text for this [DC_DialogueNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var dialogueNode:DC_DialogueNode = # a pre-configured node from the scene tree
##
## # Get the current text
## print(dialogueNode.text)  # output: "hello"
## 
## # Set the text
## dialogueNode.text = "hello there"
## [/codeblock]
var text:String:
	set(newText):
		textField.text = newText
	get():
		return textField.text

## Used to get and set the type for this [DC_DialogueNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## Valid types can be found in [member DialogueDefaults.DIALOGUE_TYPES].
## [br][br]
## Usage:
## [codeblock]
## var dialogueNode:DC_DialogueNode = # a pre-configured node from the scene tree
##
## # Get the current type
## print(dialogueNode.type)  # output: "neutral"
## 
## # Set the type
## dialogueNode.type = "happy"
## [/codeblock]
var type:String:
	set(newType):
		typeField.option = newType
	get():
		return typeField.option

## Used to get and set the mode for this [DC_DialogueNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## Valid modes can be found in [member DialogueDefaults.DIALOGUE_MODES].
## [br][br]
## Usage:
## [codeblock]
## var dialogueNode:DC_DialogueNode = # a pre-configured node from the scene tree
##
## # Get the current mode
## print(dialogueNode.mode)  # output: "normal"
## 
## # Set the mode
## dialogueNode.mode = "hectic"
## [/codeblock]
var mode:String:
	set(newMode):
		modeField.option = newMode
	get():
		return modeField.option

## Used to get and set the SFX IDs for each SFX event this [DC_DialogueNode] has.
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## Valid SFX IDs can be found in "res://sounds/sfx/".  The IDs will be the names of all folders found there.
## [br][br]
## Usage:
## [codeblock]
## var dialogueNode:DC_DialogueNode = # a pre-configured node from the scene tree
##
## # Get the currently set SFX events
## print(dialogueNode.sfxEventAspects)  # output: {"eventId1": "sfxId1", "eventId2": "sfxId2"}
## 
## # Set the SFX IDs for some SFX events
## dialogueNode.sfxEventAspects = {
## 	"eventId1": "sfxId1",
## 	"eventId2": "sfxId2"
## }
## [/codeblock]
var sfxEventAspects:Dictionary:
	set(newSfxEventAspects):
		sfxEventAspectsHandler.aspects = newSfxEventAspects
	get():
		return sfxEventAspectsHandler.aspects
## The [member id] of the [DC_DialogueNode] to load when a player fails a hectic dialogue interaction.
var nextOnHecticFailId:String = ""
var _nextOnHecticPortEnabled:bool = false
## The current connection between this "Next On Hectic Fail" port and a [DC_DialogueNode].
var nextOnHecticPortConnection:Dictionary = {
	"me": "",
	"mePort": 0,
	"toNode": "",
	"toPort": 0
}

## Used to get and set the write speed preset for this [DC_DialogueNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually click-set them.
## Valid types can be found in [member DialogueDefaults.WRITE_SPEED_PRESETS]'s keys.
## [br][br]
## Usage:
## [codeblock]
## var dialogueNode:DC_DialogueNode = # a pre-configured node from the scene tree
##
## # Get the current write speed preset
## print(dialogueNode.writeSpeedPreset)  # output: "medium"
## 
## # Set the write speed preset
## dialogueNode.writeSpeedPreset = "fast"
## [/codeblock]
var writeSpeedPreset:String:
	set(newPreset):
		writeSpeedAspectsHandler.preset = newPreset
	get():
		return writeSpeedAspectsHandler.preset

## Used to get and set the write speed value for this [DC_DialogueNode].
## Has a custom getter and setter so you can just use it like a normal variable while also updating the fields as if you manually set them.
## [br][br]
## Usage:
## [codeblock]
## var dialogueNode:DC_DialogueNode = # a pre-configured node from the scene tree
##
## # Get the current write speed
## print(dialogueNode.writeSpeedValue)  # output: 60
## 
## # Set the write speed
## dialogueNode.writeSpeedValue = 45
## [/codeblock]
var writeSpeedValue:float:
	set(newSpeed):
		writeSpeedAspectsHandler.value = newSpeed
	get():
		return writeSpeedAspectsHandler.value

## The number of option ports that currently exist for this [DC_DialogueNode].
var numOptions:int = 0:
	set(value):
		if value >= 0:
			numOptions = value

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]  The data of each option node connected to the option ports.
var _options:Array[Dictionary] = []
## [b]Internal-use only.[/b]  The labels for each option port.
var _optionPorts:Array[Label] = []

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	super()
	set_slot_color_left(DIALOGUE_ID_PORT, PortColor.DIALOGUE)
	set_slot_type_left(DIALOGUE_ID_PORT, PortType.DIALOGUE)
	
	sfxEventAspects = DialogueDefaults.DEFAULT_DIALOGUE.sfx

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Creates an option port for thie [DC_DialogueNode] under the buttons that let you create and remove option ports.
func createOptionPort() -> void:
	var optionLabel:Label = _OPTION_LABEL_SCENE.instantiate()
	_optionPorts.push_back(optionLabel)
	
	add_child(optionLabel)
	move_child(optionLabel, _NUM_NODES_ABOVE_OPTIONS + numOptions)
	optionLabel.text = str(numOptions)
	optionLabel.theme_type_variation = "LabelOption"
	
	if _nextOnHecticPortEnabled:
		_shiftHecticPort(1)
	
	set_slot(_NUM_NODES_ABOVE_OPTIONS + numOptions,
		false, 0, Color.TRANSPARENT,
		true, PortType.OPTION, PortColor.OPTION
	)
	_options.push_back({})
	numOptions += 1
	
	_option_amount_changed.emit()

## Returns the currently configured fields for thie [DC_DialogueNode].
## If a field matches its corresponding field in [member DialogueDefaults.DEFAULT_DIALOGUE],
## it is not included in the return payload.
func getFields() -> Dictionary:
	var currentValues:Dictionary = {
		"id": dialogueIDField.text,
		"text": textField.text,
	}
	
	# text theme (unused atm)
	
	currentValues.type = type
	currentValues.mode = mode
	
	if mode == "hectic" and not nextOnHecticFailId:
		# TODO:  make the warning pop up on screen
		printerr("Next On Hectic Fail not set!")
	else:
		if nextOnHecticFailId:
			currentValues.nextOnHecticFailureID = nextOnHecticFailId
	
	if writeSpeedPreset != DialogueDefaults.DEFAULT_DIALOGUE.writeSpeed:
		currentValues.writeSpeed = writeSpeedPreset
		if currentValues.writeSpeed == "custom":
			currentValues.writeSpeedCustom = writeSpeedAspectsHandler.value
	
	if sfxEventAspects != {}:
		currentValues.sfx = sfxEventAspects
	
	# background theme (unused atm)
	# particles (unused atm)
	
	if _options != []:
		var optionsToAdd:Array[Dictionary] = []
		for option in _options:
			if option == {}:
				continue
			optionsToAdd.push_back(option)
		
		if optionsToAdd != []:
			currentValues.options = optionsToAdd
	
	return currentValues

## Generates a dictionary with all of the set fields and sends it to anyone listening to the [signal save_me] signal.
func saveToFile() -> void:
	var data:Dictionary = getFields()
		
	if data.id == "":
		printerr("DC_DialogueNode/saveToFile(): Dialogue Object ID not set.")
	
	save_me.emit(data)

## Updates an option from an internal list of options to be empty.
func optionDisconnected(port:int) -> void:
	_options[port] = {}

## Updates [member nextOnHecticFailId] to be an empty string.
func nextOnHecticFailIdDisconnected() -> void:
	nextOnHecticFailId = ""

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]  Removes an option port.
func _removeOptionPort() -> void:
	if _optionPorts.is_empty():
		return
	
	if _nextOnHecticPortEnabled:
		_shiftHecticPort(-1)
	
	numOptions -= 1
	var toRemove:Label = _optionPorts.pop_back()
	clear_slot(_NUM_NODES_ABOVE_OPTIONS + numOptions)
	_options.pop_back()
	toRemove.queue_free()
	
	disconnect_option.emit(name, numOptions)
	
	_option_amount_changed.emit()

## [b]Internal-use only.[/b]  Moves the Hectic port up/down when the number
## of option ports decreases/increases.
func _shiftHecticPort(amount:int) -> void:
	var currentSlot:int = _NUM_NODES_ABOVE_OPTIONS + numOptions
	
	disconnect_hectic_port.emit(name, numOptions)
	set_slot(currentSlot,
		false, 0, Color.TRANSPARENT,
		false, 0, Color.TRANSPARENT
	)
	
	await _option_amount_changed
	
	set_slot(currentSlot + amount,
		false, 0, Color.TRANSPARENT,
		true, PortType.DIALOGUE, PortColor.DIALOGUE
	)
	nextOnHecticPortConnection.mePort += amount
	reconnect_hectic_port.emit(nextOnHecticPortConnection)
	_on_resize_height()

## [b]Internal-use only.[/b]  Disconnects all connections to itself, then prepares for deletion.
func _delete() -> void:
	disconnect_all_options.emit()
	disconnect_id.emit()
	super()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]  Handles logic for when the save button is pressed.
func _on_save_pressed() -> void:
	saveToFile()

## [b]Internal-use only.[/b]  Handles logic for when the add option button is pressed.
func _on_add_option_pressed() -> void:
	createOptionPort()

## [b]Internal-use only.[/b]  Handles logic for when the remove option button is pressed.
func _on_remove_option_pressed() -> void:
	_removeOptionPort()

## [b]Internal-use only.[/b]  Handles logic for when a connected
## [DC_OptionNode]'s attributes get updated.
func _on_option_updated(index:int, newValue:Dictionary) -> void:
	_options[index] = newValue

## [b]Internal-use only.[/b]  Handles logic for when a connected
## [DC_OptionNode] gets disconnected from an option port.
func _on_option_disconnected(port:int) -> void:
	optionDisconnected(port)

## [b]Internal-use only.[/b]  Handles logic for when a [DC_DialogueNode]
## gets connected to the Hectic port.
func _on_set_hectic_port(on: bool) -> void:
	if not on:
		disconnect_hectic_port.emit(name, numOptions)
	
	set_slot(_NUM_NODES_ABOVE_OPTIONS + numOptions,
		false, 0, Color.TRANSPARENT,
		on, PortType.DIALOGUE, PortColor.DIALOGUE
	)
	_nextOnHecticPortEnabled = on

## [b]Internal-use only.[/b]  Handles logic for when the [DC_DialogueNode]'s
## ID get updated.
func _on_hectic_fail_updated(newID:String) -> void:
	nextOnHecticFailId = newID

## [b]Internal-use only.[/b]  Handles logic for when a [DC_DialogueNode]
## connected to the Hectic port gets disconnected.
func _on_hectic_fail_disconnected() -> void:
	nextOnHecticFailIdDisconnected()

## [b]Internal-use only.[/b]  Handles logic for when the debug button gets pressed.
func _on_debug_pressed() -> void:
	print("------ ", title, " ------")
	print("Text: ", text)
	print("Options: ", _options)
	print("OptionPorts: ", _optionPorts)
	print("numOptions: ", numOptions)
	print("Type: ", typeField.option)
	print("Mode: ", modeField.option)
	
	if modeField.option == "hectic":
		print("Next On Hectic Fail: ", nextOnHecticFailId)
	
	if writeSpeedAspectsHandler.preset != DialogueDefaults.DEFAULT_DIALOGUE.writeSpeed:
		print("Write Speed Preset: ", writeSpeedAspectsHandler.preset)
		print("Write Speed Value: ", writeSpeedAspectsHandler.value)
	
	var aspects:Dictionary = sfxEventAspectsHandler.aspects
	if aspects != {}:
		print("SFX Aspects:")
		for event in aspects:
			print("\t", event, ": ", aspects[event])

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
