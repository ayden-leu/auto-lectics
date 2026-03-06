extends Control
class_name DialogueCreator

# Referenced:
# 	https://www.youtube.com/watch?v=ZD9X3uvyWmg

@export var npcNameField:LineEdit

@onready var dialogueObjectScene:PackedScene = preload("uid://c5o5n3jy08obe")
@onready var dialogueOptionObjectScene:PackedScene = preload("uid://drh1uormkjsbh")
@onready var graphArea:GraphEdit = $GraphEdit

var initialObjectPosition:Vector2 = Vector2(100, 100)
var dialogueObjects:Array[DC_DialogueObject] = []
var dialogueOptions:Array[DC_DialogueOption] = []
var loadingDialogueFiles:bool = false

var savePath:String = Globals.STORAGE_PATH.DIALOGUE
var fileExtension:String = ".json"

func createObject(obj:DC_BaseObject) -> void:
	obj.disconnect_all.connect(_on_base_object_disconnect_all)
	obj.deleting.connect(_on_base_object_deleting)
	graphArea.add_child(obj)
	setObjectPosition(obj)

func setObjectPosition(obj:GraphNode) -> void:
	# line of code from:
	#	https://forum.godotengine.org/t/setting-position-of-graph-node-to-centre-of-graph-edit-view/49403
	obj.position_offset = (graphArea.scroll_offset + graphArea.size / 2) / graphArea.zoom - obj.size / 2

func getNode(nodeName:StringName) -> DC_BaseObject:
	# section of code from:
	#	https://stackoverflow.com/a/77131486
	var node:DC_BaseObject = graphArea.get_node(
		NodePath(nodeName)
	)
	
	return node

func deleteAllNodes() -> void:
	for _i in range(dialogueOptions.size()):
		dialogueOptions[0]._on_close_button_pressed()
		
	for _i in range(dialogueObjects.size()):
		dialogueObjects[0]._on_close_button_pressed()

func saveFile(data:Dictionary) -> void:
	if npcNameField.text == "":
		printerr("DialogueCreator/saveFile(): NPC Name is empty.")
		return
	
	var filename:String = data.id + fileExtension
	var fullPath:String = savePath + npcNameField.text + "/" + filename
	
	data.erase("id")
	print("----------")
	print("filename: ", filename)
	print("data: ", data)
	print("path: ", savePath + filename)
	print("----------")
	
	# ensure file directory exists
	DirAccess.make_dir_absolute(savePath + npcNameField.text)
	
	var file := FileAccess.open(fullPath, FileAccess.WRITE)
	if file == null:
		printerr("Failed to write: %s %d" %(fullPath) %(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data, "\t", false))
	print("Saved: ", (fullPath))
	
	file.close()

func createNodesFromFile(filename:String) -> void:
	var filePath:String = savePath + npcNameField.text + "/" + filename
	var file:FileAccess = FileAccess.open(filePath, FileAccess.READ)
	var data:Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	# create object
	_on_create_object_pressed()
	var targetObject:DC_DialogueObject = dialogueObjects.back()
	targetObject.idUpdateFromField = false
	targetObject.id = filename.split(".")[0]
	targetObject.name = targetObject.id
	targetObject.text = data.text
	
	if data.has("type"):
		targetObject.type = data.type
	
	if data.has("mode"):
		targetObject.mode = data.mode
	
	if data.has("nextOnHecticFailureID"):
		targetObject.nextOnHecticFailId = data.nextOnHecticFailureID
	
	if data.has("writeSpeed"):
		targetObject.writeSpeedPreset = data.writeSpeed
	
	if data.has("writeSpeedCustom"):
		targetObject.writeSpeedValue = data.writeSpeedCustom
	
	if data.has("sfx") and data.sfx != {}:
		targetObject.sfxEventAspects = data.sfx
	
	if not data.has("options"):
		return
	
	# create options
	var optionIndex:int = 0
	for option in data.options:
		_on_create_option_object_pressed()
		var targetOption:DC_DialogueOption = dialogueOptions.back()
		targetOption.textUpdateFromField = false
		targetOption.text = option.text
		
		if option.has("nextID"):
			targetOption.nextID = option.nextID
		
		targetObject.createOptionPort()
		
		_on_graph_edit_connection_request(
			targetObject.name, optionIndex,
			targetOption.name, targetOption.optionPort
		)
		optionIndex += 1

func loadDialogueTree() -> void:
	if npcNameField.text == "":
		printerr("DialogueCreator/loadDialogueTree(): NPC Name is empty.")
		return
	
	var tempDirAccess:DirAccess = DirAccess.open(savePath)
	if not tempDirAccess.dir_exists(npcNameField.text):
		printerr("DialogueCreator: Could not find the NPC folder: ", npcNameField.text)
		return
	
	var dialogueFileNames:PackedStringArray = ResourceLoader.list_directory(savePath + npcNameField.text)
	if dialogueFileNames.is_empty():
		printerr("DialogueCreator: Could not find any Dialogue files in NPC folder: ", npcNameField.text)
		return
	
	deleteAllNodes()
	# needed so arrangement is the same each time
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	loadingDialogueFiles = true
	
	for filename in dialogueFileNames:
		if not filename.ends_with(".json"):
			continue
		createNodesFromFile(filename)
	
	#await get_tree().process_frame
		
	# connect option objects to dialogue objects
	for optionObject in dialogueOptions:
		if optionObject.nextID:
			_on_graph_edit_connection_request(
				optionObject.name, optionObject.nextIDPort,
				optionObject.nextID, DC_DialogueObject.dialogueIDPort
			)
	
	#await get_tree().process_frame
	
	# connect object hectic port to object if needed
	for dialogueObject in dialogueObjects:
		if dialogueObject.nextOnHecticFailId:
			_on_graph_edit_connection_request(
				dialogueObject.name, dialogueObject.numOptions,
				dialogueObject.nextOnHecticFailId, DC_DialogueObject.dialogueIDPort
			)
	
	graphArea.arrange_nodes()
	loadingDialogueFiles = false

# --------------

func connectObjectOptionPortToOption(obj:DC_DialogueObject, option:DC_DialogueOption) -> void:
	obj.disconnect_all_options.connect(option.dialogueDisconnected)
	
	option.values_updated.connect(obj._on_option_updated)
	option.disconnect_dialogue.connect(obj.optionDisconnected)

func disconnectObjectOptionPortToOption(obj:DC_DialogueObject, option:DC_DialogueOption) -> void:
	obj.disconnect_all_options.disconnect(option.dialogueDisconnected)
	
	option.values_updated.disconnect(obj._on_option_updated)
	option.disconnect_dialogue.disconnect(obj.optionDisconnected)
	
	option.dialogueDisconnected()

func connectOptionObjectPortToObject(option:DC_DialogueOption, obj:DC_DialogueObject) -> void:
	obj.id_updated.connect(option._on_next_object_id_modified)
	obj.disconnect_id.connect(option.dialogueDisconnected)
	
	option._on_next_object_id_modified(obj.id)

func disconnectOptionObjectPortToObject(option:DC_DialogueOption, obj:DC_DialogueObject) -> void:
	obj.id_updated.disconnect(option._on_next_object_id_modified)
	obj.disconnect_id.disconnect(option.dialogueDisconnected)
	
	option._on_next_object_id_modified("")

func connectObjectHecticFailPortToObject(objFrom:DC_DialogueObject, objTo:DC_DialogueObject) -> void:
	objTo.id_updated.connect(objFrom._on_hectic_fail_updated)
	objTo.disconnect_id.connect(objFrom.nextOnHecticFailIdDisconnected)
	
	objFrom._on_hectic_fail_updated(objTo.id)

func disconnectObjectHecticFailPortToObject(objFrom:DC_DialogueObject, objTo:DC_DialogueObject) -> void:
	objTo.id_updated.disconnect(objFrom._on_hectic_fail_updated)
	objTo.disconnect_id.disconnect(objFrom.nextOnHecticFailIdDisconnected)
	
	objFrom.nextOnHecticFailIdDisconnected()

# -------------------------

func _on_create_object_pressed() -> void:
	var newObj:DC_DialogueObject = dialogueObjectScene.instantiate()
	newObj.disconnect_option.connect(_on_object_option_removed)
	newObj.save_me.connect(_on_object_save_me)
	newObj.disconnect_hectic_port.connect(_on_object_disconnect_hectic_port)
	newObj.reconnect_hectic_port.connect(_on_object_reconnect_hectic_port)
	dialogueObjects.push_back(newObj)
	createObject(newObj)

func _on_create_option_object_pressed() -> void:
	var newObj:DC_DialogueOption = dialogueOptionObjectScene.instantiate()
	dialogueOptions.push_back(newObj)
	createObject(newObj)

func _on_object_save_me(data:Dictionary) -> void:
	saveFile(data)

func _on_save_all_dialogue_pressed() -> void:
	for dialogueObject in dialogueObjects:
		dialogueObject.saveToFile()

func _on_object_option_removed(nodeName:String, port:int) -> void:
	for connection in graphArea.connections:
		if connection.from_node == nodeName and connection.from_port == port:
			var object:DC_DialogueObject = getNode(connection.from_node)
			var option:DC_DialogueOption = getNode(connection.to_node)
			
			disconnectObjectOptionPortToOption(object, option)
			
			graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)
			break

func _on_object_disconnect_hectic_port(nodeName:String, port:int) -> void:
	for connection in graphArea.connections:
		if connection.from_node == nodeName and connection.from_port == port:
			var objectFrom:DC_DialogueObject = getNode(connection.from_node)
			var objectTo:DC_DialogueObject = getNode(connection.to_node)
			
			disconnectObjectHecticFailPortToObject(objectFrom, objectTo)
			
			graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)
			break

func _on_object_reconnect_hectic_port(connection:Dictionary) -> void:
	if connection.me == "" or connection.toNode == "":
		return
	
	_on_graph_edit_connection_request(
		connection.me, connection.mePort,
		connection.toNode, connection.toPort
	)

func _on_base_object_disconnect_all(obj:DC_BaseObject) -> void:
	for connection in graphArea.connections:
		var fromNode:DC_BaseObject = getNode(connection.from_node)
		var toNode:DC_BaseObject = getNode(connection.to_node)
		
		if fromNode == obj or toNode == obj:
			graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)

func _on_base_object_deleting(obj:DC_BaseObject) -> void:
	if obj is DC_DialogueObject:
		dialogueObjects.erase(obj)
	elif obj is DC_DialogueOption:
		dialogueOptions.erase(obj)

func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# from documentation on get_connection_list_from_node()
	var fromNodeConnections = graphArea.get_connection_list_from_node(from_node)
	var fromPortConnectionAmount:int = 0
	for connection in fromNodeConnections:
		if connection.from_node == from_node and connection.from_port == from_port:
			fromPortConnectionAmount += 1

	if fromPortConnectionAmount > 0 and not loadingDialogueFiles:
		return
	
	var fromNode:DC_BaseObject = getNode(from_node)
	var toNode:DC_BaseObject = getNode(to_node)
	
	# dialogue object option port to dialogue option
	if fromNode is DC_DialogueObject and toNode is DC_DialogueOption:
		fromNode = fromNode as DC_DialogueObject
		toNode = toNode as DC_DialogueOption
		
		connectObjectOptionPortToOption(fromNode, toNode)
		toNode.port = from_port
		toNode._on_attribute_modified()
	
	# dialogue option next id port to dialogue object
	elif fromNode is DC_DialogueOption and toNode is DC_DialogueObject: 
		fromNode = fromNode as DC_DialogueOption
		toNode = toNode as DC_DialogueObject
		
		connectOptionObjectPortToObject(fromNode, toNode)
	
	# dialogue object next on hectic fail to dialogue object
	elif fromNode is DC_DialogueObject and toNode is DC_DialogueObject:
		fromNode = fromNode as DC_DialogueObject
		toNode = toNode as DC_DialogueObject
		
		connectObjectHecticFailPortToObject(fromNode, toNode)
		fromNode.nextOnHecticPortConnection.me = from_node
		fromNode.nextOnHecticPortConnection.mePort = from_port
		fromNode.nextOnHecticPortConnection.toNode = to_node
		fromNode.nextOnHecticPortConnection.toPort = to_port
	
	graphArea.connect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var fromNode:DC_BaseObject = getNode(from_node)
	var toNode:DC_BaseObject = getNode(to_node)
	
	if fromNode is DC_DialogueObject and toNode is DC_DialogueOption:
		fromNode = fromNode as DC_DialogueObject
		toNode = toNode as DC_DialogueOption
		
		disconnectObjectOptionPortToOption(fromNode, toNode)
		fromNode.optionDisconnected(from_port)
	
	elif fromNode is DC_DialogueOption and toNode is DC_DialogueObject: 
		fromNode = fromNode as DC_DialogueOption
		toNode = toNode as DC_DialogueObject
		
		disconnectOptionObjectPortToObject(fromNode, toNode)
	
	elif fromNode is DC_DialogueObject and toNode is DC_DialogueObject:
		fromNode = fromNode as DC_DialogueObject
		toNode = toNode as DC_DialogueObject
		
		disconnectObjectHecticFailPortToObject(fromNode, toNode)
	
	graphArea.disconnect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_delete_nodes_request(nodes: Array[StringName]) -> void:
	for nodeName in nodes:
		var node:DC_BaseObject = getNode(nodeName)
		node._on_close_button_pressed()


func _on_item_rect_changed() -> void:
	var newSize:Vector2 = Globals.getScreenSize()
	set_deferred("size", newSize)
	$Background.set_deferred("size", newSize)
	$MenuButtons.set_deferred("position.x", newSize.x - 11)
	if graphArea:
		graphArea.set_deferred("size", newSize)
