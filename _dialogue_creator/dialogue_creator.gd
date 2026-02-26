extends Control

# Referenced:
# 	https://www.youtube.com/watch?v=ZD9X3uvyWmg
# 	

@onready var dialogueObjectScene:PackedScene = preload("uid://c5o5n3jy08obe")
@onready var dialogueOptionObjectScene:PackedScene = preload("uid://drh1uormkjsbh")
@onready var graphArea:GraphEdit = $GraphEdit

var initialObjectPosition:Vector2 = Vector2(100, 100)

func setObjectPosition(obj:GraphNode) -> void:
	# line of code from:
	#	https://forum.godotengine.org/t/setting-position-of-graph-node-to-centre-of-graph-edit-view/49403
	obj.position_offset = (graphArea.scroll_offset + graphArea.size / 2) / graphArea.zoom - obj.size / 2

func _on_create_object_pressed() -> void:
	var newObj:GraphNode = dialogueObjectScene.instantiate()
	graphArea.add_child(newObj)
	setObjectPosition(newObj)

func _on_create_option_object_pressed() -> void:
	var newObj:GraphNode = dialogueOptionObjectScene.instantiate()
	graphArea.add_child(newObj)
	setObjectPosition(newObj)


func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graphArea.connect_node(from_node, from_port, to_node, to_port)
