extends Control
class_name DialogueCreator

# Referenced:
# 	https://www.youtube.com/watch?v=ZD9X3uvyWmg

@onready var dialogueObjectScene:PackedScene = preload("uid://c5o5n3jy08obe")
@onready var dialogueOptionObjectScene:PackedScene = preload("uid://drh1uormkjsbh")
@onready var graphArea:GraphEdit = $GraphEdit

var initialObjectPosition:Vector2 = Vector2(100, 100)
var dialogueObjects:Array[DC_DialogueObject] = []

func createObject(obj:DC_Object) -> void:
	obj.disconnect_all.connect(_on_object_being_deleted)
	graphArea.add_child(obj)
	setObjectPosition(obj)

func setObjectPosition(obj:GraphNode) -> void:
	# line of code from:
	#	https://forum.godotengine.org/t/setting-position-of-graph-node-to-centre-of-graph-edit-view/49403
	obj.position_offset = (graphArea.scroll_offset + graphArea.size / 2) / graphArea.zoom - obj.size / 2

func getNode(nodeName:StringName) -> DC_Object:
	# section of code from:
	#	https://stackoverflow.com/a/77131486
	var node:DC_Object = graphArea.get_node(
		NodePath(nodeName)
	)
	
	return node

func saveFile(data:Dictionary) -> void:
	var savePath:String = "res://dialogue_objects/"
	var npcName:String = "_testing"  # TODO:  add field for NPC name
	var filename:String = data.id + ".json"
	var fullPath:String = savePath + npcName + "/" + filename
	
	data.erase("id")
	print("filename: ", filename)
	print("data: ", data)
	print("path: ", savePath + filename)
	
	# ensure file directory exists
	DirAccess.make_dir_absolute(savePath + npcName)
	
	var f := FileAccess.open(fullPath, FileAccess.WRITE_READ)
	if f == null:
		push_error("Failed to write: %s" %(fullPath))
		push_error(FileAccess.get_open_error())
		return
	f.store_string(JSON.stringify(data, "\t", false))
	print("Saved: ", (fullPath))

# --------------

func connectDialogueObjectOptionPort(obj:DC_DialogueObject, connectObj:DC_DialogueOptionObject) -> void:
	obj.disconnect_all_right.connect(connectObj.leftPortDisconnected)

func disconnectDialogueObjectOptionPort(obj:DC_DialogueObject, connectObj:DC_DialogueOptionObject) -> void:
	obj.disconnect_all_right.disconnect(connectObj.leftPortDisconnected)

func connectDialogueOptionPortsLeft(obj:DC_DialogueOptionObject, connectedObj:DC_DialogueObject) -> void:
	obj.values_updated.connect(connectedObj._on_option_updated)
	obj.disconnect_left.connect(connectedObj.rightPortDisconnected)

func disconnectDialogueOptionPortsLeft(obj:DC_DialogueOptionObject, connectedObj:DC_DialogueObject) -> void:
	obj.values_updated.disconnect(connectedObj._on_option_updated)
	obj.disconnect_left.disconnect(connectedObj.rightPortDisconnected)
	
	obj.leftPortDisconnected()

# -------------------------

func _on_create_object_pressed() -> void:
	var newObj:DC_DialogueObject = dialogueObjectScene.instantiate()
	newObj.disconnect_right.connect(_on_dialogue_object_option_removed)
	dialogueObjects.push_back(newObj)
	createObject(newObj)

func _on_create_option_object_pressed() -> void:
	var newObj:DC_DialogueOptionObject = dialogueOptionObjectScene.instantiate()
	createObject(newObj)

func _on_save_all_dialogue_pressed() -> void:
	for dialogueObject in dialogueObjects:
		saveFile(dialogueObject.getFields())

func _on_dialogue_object_option_removed(port:int) -> void:
	for connection in graphArea.connections:
		if connection.from_port == port:
			graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)
			
			var dialogueObject:DC_Object = getNode(connection.from_node)
			var dialogueOptionObject:DC_Object = getNode(connection.to_node)
			
			disconnectDialogueObjectOptionPort(dialogueObject, dialogueOptionObject)
			
			dialogueOptionObject.leftPortDisconnected()

func _on_object_being_deleted(obj:DC_Object) -> void:
	for connection in graphArea.connections:
		var fromNode:DC_Object = getNode(connection.from_node)
		var toNode:DC_Object = getNode(connection.to_node)
		
		if fromNode == obj or toNode == obj:
			graphArea.disconnect_node(
				connection.from_node, connection.from_port,
				connection.to_node, connection.to_port
			)

func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var fromNode:DC_Object = getNode(from_node)
	var toNode:DC_Object = getNode(to_node)
	
	if fromNode is DC_DialogueObject and toNode is DC_DialogueOptionObject:
		var dialogueObject := fromNode as DC_DialogueObject
		var dialogueOptionObject := toNode as DC_DialogueOptionObject
		
		connectDialogueObjectOptionPort(dialogueObject, dialogueOptionObject)
		
		connectDialogueOptionPortsLeft(dialogueOptionObject, dialogueObject)
		dialogueOptionObject.port = from_port
		dialogueOptionObject._on_attribute_modified()
	
	graphArea.connect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var fromNode:DC_Object = getNode(from_node)
	var toNode:DC_Object = getNode(to_node)
	
	if fromNode is DC_DialogueObject and toNode is DC_DialogueOptionObject:
		var dialogueObject := fromNode as DC_DialogueObject
		var dialogueOptionObject := toNode as DC_DialogueOptionObject
		
		disconnectDialogueObjectOptionPort(dialogueObject, dialogueOptionObject)
		
		disconnectDialogueOptionPortsLeft(dialogueOptionObject, dialogueObject)
		dialogueObject.rightPortDisconnected(from_port)
	
	graphArea.disconnect_node(from_node, from_port, to_node, to_port)
