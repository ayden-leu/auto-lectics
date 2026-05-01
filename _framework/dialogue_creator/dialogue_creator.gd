extends Control
class_name DialogueCreator
## A tool for creating dialogue files to be used in-game.

signal _set_node_visibility(visible:bool)

# Referenced:
# 	https://www.youtube.com/watch?v=ZD9X3uvyWmg

@export var _npcNameField:LineEdit
@export var _background:ColorRect
@export var _menuButtons:Control
@export var _sidePanel:Control

@onready var _dialogueNodeScene:PackedScene = preload("uid://c5o5n3jy08obe")
@onready var _optionNodeScene:PackedScene = preload("uid://drh1uormkjsbh")
@onready var _graphArea:GraphEdit = $GraphEdit

#const initialObjectPosition:Vector2 = Vector2(100, 100)
const _SAVE_PATH:String = FR_Globals.STORAGE_PATH.DIALOGUE
const _FILE_EXTENSION:String = FR_Globals.DIALOGUE_FILE_TYPE

var _dialogueNodes:Array[DC_DialogueNode] = []
var _optionNodes:Array[DC_OptionNode] = []
## If the creator is currently in the process of creating dialogue and option nodes from a dialogue tree.
var loadingDialogueFiles:bool = false

var npcDefaults:Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return

func _configureNode(node:DC_BaseNode) -> void:
	node.disconnect_all.connect(_on_base_node_disconnect_all)
	node.deleting.connect(_on_base_node_deleting)
	_graphArea.add_child(node)
	_setNodePosition(node)

func _setNodePosition(obj:DC_BaseNode) -> void:
	# line of code from:
	#	https://forum.godotengine.org/t/setting-position-of-graph-node-to-centre-of-graph-edit-view/49403
	obj.position_offset = (_graphArea.scroll_offset + _graphArea.size / 2) / _graphArea.zoom - obj.size / 2

## Obtains a [DC_BaseNode] reference to one of the [GraphEdit]'s children by the node's name. 
func getNode(nodeName:StringName) -> DC_BaseNode:
	# section of code from:
	#	https://stackoverflow.com/a/77131486
	var node:DC_BaseNode = _graphArea.get_node(
		NodePath(nodeName)
	)
	
	return node

func _deleteAllNodes() -> void:
	for _i in range(_optionNodes.size()):
		_optionNodes[0]._on_close_button_pressed()
		
	for _i in range(_dialogueNodes.size()):
		_dialogueNodes[0]._on_close_button_pressed()

func _saveFile(data:Dictionary) -> void:
	if _npcNameField.text == "":
		printerr("DialogueCreator/_saveFile(): NPC Name is empty.")
		return
	
	var filename:String = data.id + _FILE_EXTENSION
	var fullPath:String = _SAVE_PATH + _npcNameField.text + "/" + filename
	
	data.erase("id")
	print("----------")
	print("filename: ", filename)
	print("data: ", data)
	print("path: ", _SAVE_PATH + filename)
	print("----------")
	
	# ensure file directory exists
	DirAccess.make_dir_absolute(_SAVE_PATH + _npcNameField.text)
	
	var file := FileAccess.open(fullPath, FileAccess.WRITE)
	if file == null:
		printerr("Failed to write: %s %d" %(fullPath) %(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data, "\t", false))
	print("Saved: ", (fullPath))
	
	file.flush()
	file.close()

func _createNodesFromFile(filename:String) -> void:
	var filePath:String = _SAVE_PATH + _npcNameField.text + "/" + filename
	var file:FileAccess = FileAccess.open(filePath, FileAccess.READ)
	if file == null:
		printerr("DialogueCreator: Error opening file: ", filePath)
		return
	
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		printerr("DialogueCreator: Failed to parse file [", filePath, "] as JSON.")
		return
	data = data as Dictionary
	
	# create object
	_on_create_dialogue_pressed()
	var newDialogueNode:DC_DialogueNode = _dialogueNodes.back()
	_set_node_visibility.connect(newDialogueNode._on_toggle_visibility)
	newDialogueNode.idUpdateFromField = false
	newDialogueNode.id = filename.split(".")[0]
	newDialogueNode.name = newDialogueNode.id
	newDialogueNode.text = data.text
	
	if data.has("type"):
		newDialogueNode.type = data.type
	
	if data.has("mode"):
		newDialogueNode.mode = data.mode
	
	if data.has("nextOnHecticFailureID"):
		newDialogueNode.nextOnHecticFailId = data.nextOnHecticFailureID
	
	if data.has("textThemePreset"):
		newDialogueNode.textThemePreset = data.textThemePreset
	
	if data.has("writeSpeed"):
		newDialogueNode.writeSpeedPreset = data.writeSpeed
	
		if data.writeSpeed == "custom" and data.has("writeSpeedCustom"):
			newDialogueNode.writeSpeedValue = data.writeSpeedCustom
	
	if data.has("sfx") and data.sfx != {}:
		newDialogueNode.sfxEventAspects = data.sfx
	
	if not data.has("options"):
		return
	
	# create options
	var optionIndex:int = 0
	for option in data.options:
		_on_create_option_pressed()
		var newOptionNode:DC_OptionNode = _optionNodes.back()
		_set_node_visibility.connect(newOptionNode._on_toggle_visibility)
		#newOptionNode.textUpdateFromField = false
		newOptionNode.text = option.text
		
		if option.has("type"):
			newOptionNode.type = option.type
		
		if option.has("textThemePreset"):
			newOptionNode.textThemePreset = option.textThemePreset
		
		if option.has("writeSpeed"):
			newOptionNode.writeSpeedPreset = option.writeSpeed
		
		if option.has("writeSpeedCustom"):
			newOptionNode.writeSpeedValue = option.writeSpeedCustom
		
		if option.has("sfx") and option.sfx != {}:
			newOptionNode.sfxEventAspects = option.sfx
		
		if option.has("spawnDelay"):
			newOptionNode.spawnDelay = option.spawnDelay
		
		if option.has("lifetime"):
			newOptionNode.lifetime = option.lifetime
		
		if option.has("setFlags"):
			newOptionNode.setFlags = option.setFlags
		
		if option.has("checkFlags"):
			newOptionNode.checkFlags = option.checkFlags
		
		if option.has("nextID"):
			newOptionNode.nextID = option.nextID
		
		newDialogueNode.createOptionPort()
		
		_on_graph_edit_connection_request(
			newDialogueNode.name, optionIndex,
			newOptionNode.name, newOptionNode.OPTION_PORT
		)
		optionIndex += 1

func _loadDialogueTree() -> void:
	if _npcNameField.text == "":
		printerr("DialogueCreator/_loadDialogueTree(): NPC Name is empty.")
		return
	
	var tempDirAccess:DirAccess = DirAccess.open(_SAVE_PATH)
	if not tempDirAccess.dir_exists(_npcNameField.text):
		printerr("DialogueCreator: Could not find the NPC folder: ", _npcNameField.text)
		return
	
	var dialogueFileNames:PackedStringArray = ResourceLoader.list_directory(_SAVE_PATH + _npcNameField.text)
	if dialogueFileNames.is_empty():
		printerr("DialogueCreator: Could not find any Dialogue files in NPC folder: ", _npcNameField.text)
		return
	
	_deleteAllNodes()
	# needed so arrangement is the same each time
	await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	loadingDialogueFiles = true
	
	for filename in dialogueFileNames:
		if not filename.ends_with(".json"):
			continue
		_createNodesFromFile(filename)
	
	#await get_tree().process_frame
		
	# connect option objects to dialogue objects
	for optionObject in _optionNodes:
		if optionObject.nextID:
			_on_graph_edit_connection_request(
				optionObject.name, optionObject.NEXT_ID_PORT,
				optionObject.nextID, DC_DialogueNode.DIALOGUE_ID_PORT
			)
	
	#await get_tree().process_frame
	
	# connect object hectic port to object if needed
	for dialogueObject in _dialogueNodes:
		if dialogueObject.nextOnHecticFailId:
			_on_graph_edit_connection_request(
				dialogueObject.name, dialogueObject.numOptions,
				dialogueObject.nextOnHecticFailId, DC_DialogueNode.DIALOGUE_ID_PORT
			)
	
	#_set_node_visibility.emit(false)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	_graphArea.arrange_nodes()
	loadingDialogueFiles = false
	#_set_node_visibility.emit(true)

# --------------

func _connectDialogueOptionPortToOption(dialogue:DC_DialogueNode, option:DC_OptionNode) -> void:
	dialogue.disconnect_all_options.connect(option._on_dialogue_node_disconnected)
	
	option.values_updated.connect(dialogue._on_option_updated)
	option.disconnect_dialogue.connect(dialogue._on_option_disconnected)

func _disconnectDialogueOptionPortToOption(dialogue:DC_DialogueNode, option:DC_OptionNode) -> void:
	dialogue.disconnect_all_options.disconnect(option._on_dialogue_node_disconnected)
	
	option.values_updated.disconnect(dialogue._on_option_updated)
	option.disconnect_dialogue.disconnect(dialogue._on_option_disconnected)
	
	option.dialogueDisconnected()

func _connectOptionDialoguePortToDialogue(option:DC_OptionNode, dialogue:DC_DialogueNode) -> void:
	dialogue.id_updated.connect(option._on_next_object_id_modified)
	dialogue.disconnect_id.connect(option._on_dialogue_node_disconnected)
	
	option._on_next_object_id_modified(dialogue.id)

func _disconnectOptionDialoguePortToDialogue(option:DC_OptionNode, dialogue:DC_DialogueNode) -> void:
	dialogue.id_updated.disconnect(option._on_next_object_id_modified)
	dialogue.disconnect_id.disconnect(option._on_dialogue_node_disconnected)
	
	option._on_next_object_id_modified("")

func _connectDialogueHecticPortToDialogue(dialogueFrom:DC_DialogueNode, dialogueTo:DC_DialogueNode) -> void:
	dialogueTo.id_updated.connect(dialogueFrom._on_hectic_fail_updated)
	dialogueTo.disconnect_id.connect(dialogueFrom._on_hectic_fail_disconnected)
	
	dialogueFrom._on_hectic_fail_updated(dialogueTo.id)

func _disconnectDialogueHecticPortToDialogue(dialogueFrom:DC_DialogueNode, dialogueTo:DC_DialogueNode) -> void:
	dialogueTo.id_updated.disconnect(dialogueFrom._on_hectic_fail_updated)
	dialogueTo.disconnect_id.disconnect(dialogueFrom._on_hectic_fail_disconnected)
	
	dialogueFrom.nextOnHecticFailIdDisconnected()

# -------------------------

func _on_create_dialogue_pressed() -> void:
	var newDialogueNode:DC_DialogueNode = _dialogueNodeScene.instantiate()
	newDialogueNode.disconnect_option.connect(_on_option_node_removed)
	newDialogueNode.save_me.connect(_on_dialogue_node_save_me)
	newDialogueNode.disconnect_hectic_port.connect(_on_dialogue_node_disconnect_hectic_port)
	newDialogueNode.reconnect_hectic_port.connect(_on_dialogue_node_reconnect_hectic_port)
	_dialogueNodes.push_back(newDialogueNode)
	_configureNode(newDialogueNode)

func _on_create_option_pressed() -> void:
	var newOptionNode:DC_OptionNode = _optionNodeScene.instantiate()
	_optionNodes.push_back(newOptionNode)
	_configureNode(newOptionNode)

func _on_dialogue_node_save_me(data:Dictionary) -> void:
	_saveFile(data)

func _on_save_all_dialogue_pressed() -> void:
	for dialogueNode in _dialogueNodes:
		dialogueNode.saveToFile()

func _on_load_dialogue_tree_pressed() -> void:
	_loadDialogueTree()

func _on_option_node_removed(nodeName:String, port:int) -> void:
	for connection in _graphArea.connections:
		if connection.from_node == nodeName and connection.from_port == port:
			var dialogue:DC_DialogueNode = getNode(connection.from_node)
			var option:DC_OptionNode = getNode(connection.to_node)
			
			_disconnectDialogueOptionPortToOption(dialogue, option)
			
			_graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)
			break

func _on_dialogue_node_disconnect_hectic_port(nodeName:String, port:int) -> void:
	for connection in _graphArea.connections:
		if connection.from_node == nodeName and connection.from_port == port:
			var dialogueFrom:DC_DialogueNode = getNode(connection.from_node)
			var dialogueTo:DC_DialogueNode = getNode(connection.to_node)
			
			_disconnectDialogueHecticPortToDialogue(dialogueFrom, dialogueTo)
			
			_graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)
			break

func _on_dialogue_node_reconnect_hectic_port(connection:Dictionary) -> void:
	if connection.me == "" or connection.toNode == "":
		return
	
	_on_graph_edit_connection_request(
		connection.me, connection.mePort,
		connection.toNode, connection.toPort
	)

func _on_base_node_disconnect_all(node:DC_BaseNode) -> void:
	for connection in _graphArea.connections:
		var fromNode:DC_BaseNode = getNode(connection.from_node)
		var toNode:DC_BaseNode = getNode(connection.to_node)
		
		if fromNode == node or toNode == node:
			_graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)

func _on_base_node_deleting(node:DC_BaseNode) -> void:
	if node is DC_DialogueNode:
		_dialogueNodes.erase(node)
	elif node is DC_OptionNode:
		_optionNodes.erase(node)

func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# from documentation on get_connection_list_from_node()
	# limit the number of outgoing connects a port can have to 1
	var fromNodeConnections = _graphArea.get_connection_list_from_node(from_node)
	var fromPortConnectionAmount:int = 0
	for connection in fromNodeConnections:
		if connection.from_node == from_node and connection.from_port == from_port:
			fromPortConnectionAmount += 1

	if fromPortConnectionAmount > 0 and not loadingDialogueFiles:
		return
	
	var fromNode:DC_BaseNode = getNode(from_node)
	var toNode:DC_BaseNode = getNode(to_node)
	
	# dialogue object option port to dialogue option
	if fromNode is DC_DialogueNode and toNode is DC_OptionNode:
		#fromNode = fromNode as DC_DialogueNode  # mainly for code completion hints
		#toNode = toNode as DC_OptionNode        # mainly for code completion hints
		
		_connectDialogueOptionPortToOption(fromNode, toNode)
		toNode.port = from_port
		toNode._on_field_updated()
	
	# dialogue option next id port to dialogue object
	elif fromNode is DC_OptionNode and toNode is DC_DialogueNode: 
		#fromNode = fromNode as DC_OptionNode  # mainly for code completion hints
		#toNode = toNode as DC_DialogueNode    # mainly for code completion hints
		
		_connectOptionDialoguePortToDialogue(fromNode, toNode)
	
	# dialogue object next on hectic fail to dialogue object
	elif fromNode is DC_DialogueNode and toNode is DC_DialogueNode:
		#fromNode = fromNode as DC_DialogueNode  # mainly for code completion hints
		#toNode = toNode as DC_DialogueNode      # mainly for code completion hints
		
		_connectDialogueHecticPortToDialogue(fromNode, toNode)
		fromNode.nextOnHecticPortConnection = {
			"me": from_node,
			"mePort": from_port,
			"toNode": to_node,
			"toPort": to_port
		}
	
	_graphArea.connect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var fromNode:DC_BaseNode = getNode(from_node)
	var toNode:DC_BaseNode = getNode(to_node)
	
	if fromNode is DC_DialogueNode and toNode is DC_OptionNode:
		#fromNode = fromNode as DC_DialogueNode  # mainly for code completion hints
		#toNode = toNode as DC_OptionNode        # mainly for code completion hints
		
		_disconnectDialogueOptionPortToOption(fromNode, toNode)
		fromNode.optionDisconnected(from_port)
	
	elif fromNode is DC_OptionNode and toNode is DC_DialogueNode: 
		#fromNode = fromNode as DC_OptionNode  # mainly for code completion hints
		#toNode = toNode as DC_DialogueNode    # mainly for code completion hints
		
		_disconnectOptionDialoguePortToDialogue(fromNode, toNode)
	
	elif fromNode is DC_DialogueNode and toNode is DC_DialogueNode:
		#fromNode = fromNode as DC_DialogueNode  # mainly for code completion hints
		#toNode = toNode as DC_DialogueNode      # mainly for code completion hints
		
		_disconnectDialogueHecticPortToDialogue(fromNode, toNode)
	
	_graphArea.disconnect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_delete_nodes_request(nodes: Array[StringName]) -> void:
	for nodeName in nodes:
		var node:DC_BaseNode = getNode(nodeName)
		node._on_close_button_pressed()


func _on_save_defaults_pressed() -> void:
	var dialogue:Dictionary = _sidePanel.getDialogueFields()
	var option:Dictionary = _sidePanel.getOptionFields()
	
