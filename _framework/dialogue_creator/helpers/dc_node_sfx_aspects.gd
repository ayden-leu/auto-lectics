extends DC_BaseNodeField

# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------
## [b]Internal-use only.[/b]  A reference to the [DC_SfxEventFieldOption] scene.
const _SFX_EVENT_SCENE:Resource = preload("uid://citmsrjh10i13")

# ------------------------------------------------
# export variables
# ------------------------------------------------
## Holds all [DC_SfxEventFieldOption] fields that are created.
@export var eventHolder:Control
## Whether to remove the first option entry of each spawned SFX ID entry.
## Is a work-around to remove "npcDefault" from each entry.
@export var removeNpcDefaultEntry:bool
## Whether to remove the "inherit" option from the chooser pool.
## Is a work around similar to [member removeNpcDefaultEntry].
@export var removeInherit:bool

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------
## The collective configured SFX events for this [DC_DialogueNode].
## Dictionary format is the following:
## [codeblock]
## var dict:Dictionary = {
## 	"eventName": "sfxID"
## }
## [/codeblock]
var configuredEvents:Dictionary:
	get():
		return _getConfiguredEvents()
	set(newAspects):
		var keys:Array = newAspects.keys()
		var values:Array = newAspects.values()
		for i in range(keys.size()):
			_sfxEventFieldOptions[keys[i]].chosen = values[i]

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Holds all generated [DC_SfxEventFieldOption] fields
## and matches them to their corresponding [member DialogueDefaults.SFX_EVENTS] ID.
var _sfxEventFieldOptions:Dictionary[String, DC_NodeSfxEventField] = {}

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	for event in DialogueDefaults.SFX_EVENTS:
		_createEventSection(event)

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Creates a [DC_SfxEventFieldOption] field for a given event name.
func _createEventSection(eventName:String) -> void:
	if _sfxEventFieldOptions.has(eventName):
		printerr("AspectsSFX:  Field for [", eventName, "] already exists.")
		return
	
	var newEvent:DC_NodeSfxEventField = _SFX_EVENT_SCENE.instantiate()
	newEvent.eventID = eventName
	
	if removeNpcDefaultEntry:
		newEvent.removeNpcDefaultEntry()
	if removeInherit:
		newEvent.removeInherit()
	newEvent.setup()
	
	eventHolder.add_child(VSeparator.new())
	eventHolder.add_child(newEvent)
	_sfxEventFieldOptions[eventName] = newEvent
	newEvent.field_updated.connect(_on_field_updated)

## [b]Internal-use only.[/b]
## Retrieves the values of each generated [DC_SfxEventFieldOption] field.
func _getConfiguredEvents() -> Dictionary:
	var all:Dictionary = {}
	for eventFieldOption:DC_NodeSfxEventField in _sfxEventFieldOptions.values():
		if eventFieldOption.chosen != "npcDefault":
			all[eventFieldOption.eventID] = eventFieldOption.chosen
	return all

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
## [b]Internal-use only.[/b]
## Runs when a [DC_SfxEventFieldOption]'s chosen SFX ID gets updated.
func _on_field_updated() -> void:
	field_updated.emit()
	
# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
