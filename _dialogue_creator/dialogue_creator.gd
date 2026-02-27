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

var savePath:String = "res://dialogue_objects/"
var npcName:String
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

func saveFile(data:Dictionary) -> void:
	npcName = npcNameField.text
	var filename:String = data.id + fileExtension
	var fullPath:String = savePath + npcName + "/" + filename
	
	if npcName == "":
		printerr("DialogueCreator/saveFile(): NPC Name is empty.")
		return
	
	data.erase("id")
	print("----------")
	print("filename: ", filename)
	print("data: ", data)
	print("path: ", savePath + filename)
	print("----------")
	
	# ensure file directory exists
	DirAccess.make_dir_absolute(savePath + npcName)
	
	var f := FileAccess.open(fullPath, FileAccess.WRITE)
	if f == null:
		printerr("Failed to write: %s %d" %(fullPath) %(FileAccess.get_open_error()))
		return
	f.store_string(JSON.stringify(data, "\t", false))
	print("Saved: ", (fullPath))

func loadDialogueTree() -> void:
	print(dialogueOptions)
	for optionObject in dialogueOptions:
		optionObject._on_close_button_pressed()
	
	print(dialogueObjects)
	for dialogueObject in dialogueObjects:
		dialogueObject._on_close_button_pressed()
	
	npcName = npcNameField.text
	if npcName == "":
		printerr("DialogueCreator/loadDialogueTree(): NPC Name is empty.")
		return
	
	var tempDirAccess:DirAccess = DirAccess.open(savePath)
	if not tempDirAccess.dir_exists(npcName):
		printerr("DialogueCreator: Could not find the NPC folder: ", npcName)
	
	var dialogueFilePath:String = savePath + npcName
	var dialogueFileNames:PackedStringArray = ResourceLoader.list_directory(dialogueFilePath)
	if dialogueFileNames.is_empty():
		printerr("DialogueCreator: Could not find any Dialogue files in NPC folder: ", npcName)
	
	for filename in dialogueFileNames:
		if not filename.ends_with(".json"):
			continue
		
		var filePath:String = dialogueFilePath + "/" + filename
		var file:FileAccess = FileAccess.open(filePath, FileAccess.READ)
		var data:Dictionary = JSON.parse_string(file.get_as_text())
		
		# create object
		_on_create_object_pressed()
		var targetObject:DC_DialogueObject = dialogueObjects.back()
		targetObject.idUpdateFromField = false
		targetObject.id = filename.split(".")[0]
		targetObject.name = targetObject.id
		targetObject.text = data.text
		
		if not data.has("options"):
			continue
		
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
				targetOption.name, 0
			)
			optionIndex += 1
	
	for optionObject in dialogueOptions:
		if optionObject.nextID:
			_on_graph_edit_connection_request(
				optionObject.name, 0,
				optionObject.nextID, 0
			)
	
	await get_tree().create_timer(0.0001).timeout
	
	for optionObject in dialogueOptions:
		graphArea.set_selected(optionObject)
	for dialogueObject in dialogueObjects:
		graphArea.set_selected(dialogueObject)
	
	graphArea.arrange_nodes()

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
	option.nextID = obj.id
	obj.id_updated.connect(option._on_next_object_id_modified)

func disconnectOptionObjectPortToObject(option:DC_DialogueOption, obj:DC_DialogueObject) -> void:
	option.nextID = ""
	obj.id_updated.disconnect(option._on_next_object_id_modified)

# -------------------------

func _on_create_object_pressed() -> void:
	var newObj:DC_DialogueObject = dialogueObjectScene.instantiate()
	newObj.disconnect_option.connect(_on_dialogue_object_option_removed)
	dialogueObjects.push_back(newObj)
	createObject(newObj)

func _on_create_option_object_pressed() -> void:
	var newObj:DC_DialogueOption = dialogueOptionObjectScene.instantiate()
	dialogueOptions.push_back(newObj)
	createObject(newObj)

func _on_save_all_dialogue_pressed() -> void:
	for dialogueObject in dialogueObjects:
		var data:Dictionary = dialogueObject.getFields()
		
		if data.id == "":
			printerr("DialogueCreator/_on_save_all_dialogue_pressed(): Dialogue Object ID not set.")
			continue
		
		saveFile(data)

func _on_dialogue_object_option_removed(port:int) -> void:
	for connection in graphArea.connections:
		if connection.from_port == port:
			graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)
			
			var object:DC_DialogueObject = getNode(connection.from_node)
			var option:DC_DialogueOption = getNode(connection.to_node)
			
			disconnectObjectOptionPortToOption(object, option)
			
			option.dialogueDisconnected()

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
	var fromNode:DC_BaseObject = getNode(from_node)
	var toNode:DC_BaseObject = getNode(to_node)
	
	if fromNode is DC_DialogueObject and toNode is DC_DialogueOption:
		fromNode = fromNode as DC_DialogueObject
		toNode = toNode as DC_DialogueOption
		
		connectObjectOptionPortToOption(fromNode, toNode)
		toNode.port = from_port
		toNode._on_attribute_modified()
	
	if fromNode is DC_DialogueOption and toNode is DC_DialogueObject: 
		fromNode = fromNode as DC_DialogueOption
		toNode = toNode as DC_DialogueObject
		
		connectOptionObjectPortToObject(fromNode, toNode)
	
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
	
	graphArea.disconnect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_delete_nodes_request(nodes: Array[StringName]) -> void:
	for nodeName in nodes:
		var node:DC_BaseObject = getNode(nodeName)
		node._on_close_button_pressed()
