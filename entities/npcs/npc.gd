extends Node3D
class_name NPC

@onready var dialogueBoxScene: Resource = preload(Globals.SCENES.DialogueBox)
@onready var dialogueBoxAnchor: Marker3D = $DialogueBoxAnchor
var dialogueBox: DialogueBox = null
var isTalking: bool = false

# --- NEW: JSON dialogue setup ---
@export var dialogue_folder: String = "res://dialogue_objects/NPC_Test/"
@export var starting_dialogue_id: String = "Dialogue1a" # e.g. "Dialogue1a"

# Optional: if you still want "idleDialogueIndex" behaviour, you can swap starting_dialogue_id at runtime
var current_dialogue_id: String = ""

var delayStartShowingOptions: float = 1.0

var loader := DialogueLoader.new()

func _ready() -> void:
	current_dialogue_id = starting_dialogue_id

func _process(_delta: float) -> void:
	pass

func spawnDialogue() -> void:
	if dialogueBox != null:
		return

	dialogueBox = dialogueBoxScene.instantiate()

	# IMPORTANT CHANGE:
	# DialogueBox should emit "update_me" with the option's nextID (String),
	# not an array index. If it currently emits an int, update DialogueBox (see below).
	dialogueBox.connect("update_me", Callable(self, "loadNextDialogue"))

	dialogueBoxAnchor.add_child(dialogueBox)

func _dialogue_path_from_id(id: String) -> String:
	return dialogue_folder + id + ".json"

func _load_dialogue_node(id: String) -> Dictionary:
	var path := _dialogue_path_from_id(id)
	var dlg := loader.load_dialogue_node_file(path)
	if dlg.is_empty():
		push_warning("NPC: Failed to load dialogue id '%s' at '%s'" % [id, path])
	return dlg

# Adapter: convert loaded JSON dict into what your DialogueBox expects
func loadData(dlg: Dictionary) -> void:
	# Your DialogueBox expects:
	# dialogueBox.text = dialogueEntry.initial
	# dialogueBox.optionData = dialogueEntry.options
	#
	# Our loader returns:
	# dlg["text"] and dlg["options"] (options include "text", "spawnDelay", "nextID", etc.)

	dialogueBox.text = dlg.get("text", "")

	# If your DialogueBox expects option keys exactly: text/type/spawnDelay/nextID, we're good.
	# If it expects different keys, remap here.
	dialogueBox.optionData = dlg.get("options", [])

func loadNextDialogue(next_id: Variant) -> void:
	# next_id should be a String ("" means end).
	# But depending on your signal, it could come in as Variant; handle safely.
	var id_str := ""
	if typeof(next_id) == TYPE_STRING:
		id_str = next_id
	elif typeof(next_id) == TYPE_INT:
		# If DialogueBox still sends ints, this is legacy behaviour; end safely.
		push_warning("NPC: DialogueBox sent int next_id. Update DialogueBox to send nextID String.")
		id_str = ""
	else:
		id_str = str(next_id)

	if id_str == "":
		_end_dialogue()
		return

	current_dialogue_id = id_str

	var dlg := _load_dialogue_node(current_dialogue_id)
	if dlg.is_empty():
		_end_dialogue()
		return

	loadData(dlg)

	await get_tree().create_timer(delayStartShowingOptions).timeout

	var options: Array = dlg.get("options", [])
	if options.size() == 0:
		_end_dialogue()
		return

	dialogueBox.createOptions()

func _end_dialogue() -> void:
	if dialogueBox != null:
		dialogueBox.kill()
		dialogueBox = null
	isTalking = false

func _onInteraction() -> void:
	if isTalking:
		return

	isTalking = true
	spawnDialogue()

	# Start at starting_dialogue_id
	loadNextDialogue(starting_dialogue_id)
