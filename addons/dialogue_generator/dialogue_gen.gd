@tool
extends Control

#const DialogueDB = preload("res://addons/dialogue_generator/dialogue_db.gd
#")

var db := DialogueDB.new()
var current_path: String = ""

# UI
var open_dialog: FileDialog
var save_dialog: FileDialog
var graph: GraphEdit
var inspector: VBoxContainer
var search_box: LineEdit
var dialogue_list: ItemList

# Selection state
var selected_node_id: String = ""
var selected_option_index: int = -1

func _ready() -> void:
	printerr("WARNING: I don't know how you're using dialogue_gen.gd as opening it gives a bunch of errors in the console output.")
	_build_ui()

func _build_ui() -> void:
	# Root layout: left list, center graph, right inspector
	var root := HSplitContainer.new()
	root.size_flags_horizontal = SIZE_EXPAND_FILL
	root.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(root)

	# LEFT
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(260, 0)
	root.add_child(left)

	var toolbar := HBoxContainer.new()
	left.add_child(toolbar)

	var btn_open := Button.new()
	btn_open.text = "Open"
	btn_open.pressed.connect(_on_open_pressed)
	toolbar.add_child(btn_open)

	var btn_save := Button.new()
	btn_save.text = "Save"
	btn_save.pressed.connect(_on_save_pressed)
	toolbar.add_child(btn_save)

	var btn_new := Button.new()
	btn_new.text = "New"
	btn_new.pressed.connect(_on_new_pressed)
	toolbar.add_child(btn_new)

	search_box = LineEdit.new()
	search_box.placeholder_text = "Search id/text..."
	search_box.text_changed.connect(_refresh_dialogue_list)
	left.add_child(search_box)

	dialogue_list = ItemList.new()
	dialogue_list.size_flags_vertical = SIZE_EXPAND_FILL
	dialogue_list.item_selected.connect(_on_dialogue_selected)
	left.add_child(dialogue_list)

	var btn_add := Button.new()
	btn_add.text = "Add Dialogue"
	btn_add.pressed.connect(_on_add_dialogue)
	left.add_child(btn_add)

	# CENTER (Graph)
	graph = GraphEdit.new()
	graph.size_flags_horizontal = SIZE_EXPAND_FILL
	graph.size_flags_vertical = SIZE_EXPAND_FILL
	graph.connection_request.connect(_on_connection_request)
	graph.disconnection_request.connect(_on_disconnection_request)
	graph.node_selected.connect(_on_graph_node_selected)
	root.add_child(graph)

	# RIGHT (Inspector)
	inspector = VBoxContainer.new()
	inspector.custom_minimum_size = Vector2(320, 0)
	root.add_child(inspector)
	_build_inspector_placeholder()

	# File dialogs
	open_dialog = FileDialog.new()
	open_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	open_dialog.access = FileDialog.ACCESS_RESOURCES
	open_dialog.filters = PackedStringArray(["*.json ; JSON files"])
	open_dialog.file_selected.connect(_on_open_file_selected)
	add_child(open_dialog)

	save_dialog = FileDialog.new()
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.access = FileDialog.ACCESS_RESOURCES
	save_dialog.filters = PackedStringArray(["*.json ; JSON files"])
	save_dialog.file_selected.connect(_on_save_file_selected)
	add_child(save_dialog)

	# Start empty
	_refresh_dialogue_list()
	_rebuild_graph()

func _build_inspector_placeholder() -> void:
	_queue_free_children(inspector)

	var lbl := Label.new()
	lbl.text = "Select a dialogue node (or an option port connection) to edit."
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector.add_child(lbl)

var temp_typeOption:Dictionary = {
	"Neutral": 0,
	"Happy": 1,
	"Angry": 2,
	"Confused": 3,
	"Sad": 4
}

var temp_typeDialogue:Dictionary = {
	"Normal": 0,
	"Hectic": 1
}

func _build_inspector_for_dialogue(d: Dictionary) -> void:
	_queue_free_children(inspector)

	var title := Label.new()
	title.text = "Dialogue: %s" % str(d.get("id", ""))
	title.add_theme_font_size_override("font_size", 16)
	inspector.add_child(title)

	# Text
	inspector.add_child(Label.new())
	inspector.get_child(inspector.get_child_count()-1).text = "Text"

	var text_edit := TextEdit.new()
	text_edit.text = str(d.get("text", ""))
	text_edit.custom_minimum_size = Vector2(0, 120)
	text_edit.text_changed.connect(func():
		d["text"] = text_edit.text
		_refresh_dialogue_list()
	)
	inspector.add_child(text_edit)

	# Type
	inspector.add_child(Label.new())
	inspector.get_child(inspector.get_child_count()-1).text = "Type"

	var type_opt := OptionButton.new()
	for t in ["Neutral", "Happy", "Angry", "Confused", "Sad"]:
		type_opt.add_item(t, temp_typeOption[t])
	var cur_t := str(d.get("type", "Neutral"))
	var index := type_opt.get_item_index(temp_typeOption[cur_t])
	type_opt.select(index if index != -1 else 0)

	type_opt.item_selected.connect(func(idx: int):
		d["type"] = type_opt.get_item_text(idx)
	)
	inspector.add_child(type_opt)

	# Mode
	inspector.add_child(Label.new())
	inspector.get_child(inspector.get_child_count()-1).text = "Mode"

	var mode_opt := OptionButton.new()
	for m in ["Normal", "Hectic"]:
		mode_opt.add_item(m)
	var cur_m := str(d.get("mode", "Normal"))
	mode_opt.select(max(0, mode_opt.get_item_index(temp_typeDialogue[cur_m])))
	mode_opt.item_selected.connect(func(idx: int):
		d["mode"] = mode_opt.get_item_text(idx)
	)
	inspector.add_child(mode_opt)

	# Options
	var opts: Array = d.get("options", [])
	var opts_label := Label.new()
	opts_label.text = "Options (%d)" % opts.size()
	opts_label.add_theme_font_size_override("font_size", 14)
	inspector.add_child(opts_label)

	var btn_add_opt := Button.new()
	btn_add_opt.text = "Add Option"
	btn_add_opt.pressed.connect(func():
		db.add_option(str(d.get("id","")), "Option %d" % (opts.size()+1))
		_rebuild_graph()
		_build_inspector_for_dialogue(d)
	)
	inspector.add_child(btn_add_opt)

	for i in range(opts.size()):
		var opt = opts[i]
		if typeof(opt) != TYPE_DICTIONARY: continue

		var row := VBoxContainer.new()
		row.add_child(Label.new())
		row.get_child(0).text = "Option %d" % (i+1)

		var le := LineEdit.new()
		le.text = str(opt.get("text", ""))
		le.text_changed.connect(func(new_text: String):
			opt["text"] = new_text
			# Update node port name
			_update_node_ports(str(d.get("id","")))
		)
		row.add_child(le)
		
		print(opt)

		var next_lbl := Label.new()
		next_lbl.text = "nextID: %s" % DialogueDB._get_next_id(opt)
		row.add_child(next_lbl)

		var btn_clear := Button.new()
		btn_clear.text = "Clear nextID"
		btn_clear.pressed.connect(func():
			DialogueDB._set_next_id(opt, "")
			_rebuild_graph()
			_build_inspector_for_dialogue(d)
		)
		row.add_child(btn_clear)

		inspector.add_child(row)

func _update_node_ports(dialogue_id: String) -> void:
	var node := graph.get_node_or_null(dialogue_id)
	if node == null or not (node is GraphNode):
		return
	# Re-label ports based on option text
	var d := db.by_id.get(dialogue_id, {})
	var opts: Array = d.get("options", [])
	for i in range(opts.size()):
		var label := str(opts[i].get("text", "Option"))
		(node as GraphNode).set_slot(i, false, 0, Color(), true, 0, Color())
		(node as GraphNode).set_slot_enabled_right(i, true)
		(node as GraphNode).set_slot_enabled_left(i, false)
		(node as GraphNode).set_slot_color_right(i, Color.WHITE)
		(node as GraphNode).set_slot_type_right(i, 0)
		(node as GraphNode).set_slot_color_left(i, Color.WHITE)
		(node as GraphNode).set_slot_type_left(i, 0)
		(node as GraphNode).set_slot_title_right(i, label)

func _on_open_pressed() -> void:
	open_dialog.popup_centered_ratio(0.7)

func _on_save_pressed() -> void:
	if current_path == "":
		save_dialog.popup_centered_ratio(0.7)
	else:
		db.save_json(current_path)

func _on_new_pressed() -> void:
	current_path = ""
	db.dialogues = []
	db.rebuild_index()
	selected_node_id = ""
	_refresh_dialogue_list()
	_rebuild_graph()
	_build_inspector_placeholder()

func _on_open_file_selected(path: String) -> void:
	current_path = path
	db.load_json(path)
	_refresh_dialogue_list()
	_rebuild_graph()
	_build_inspector_placeholder()

func _on_save_file_selected(path: String) -> void:
	current_path = path
	db.save_json(path)

func _on_add_dialogue() -> void:
	# Create a unique id
	var base := "D"
	var n := db.by_id.size() + 1
	var id := "%s%03d" % [base, n]
	while db.by_id.has(id):
		n += 1
		id = "%s%03d" % [base, n]
	db.ensure_dialogue(id)
	_refresh_dialogue_list()
	_rebuild_graph()
	_focus_node(id)

func _refresh_dialogue_list(_t: String = "") -> void:
	if dialogue_list == null:
		return
	dialogue_list.clear()

	var q := search_box.text.strip_edges().to_lower()
	for d in db.dialogues:
		if typeof(d) != TYPE_DICTIONARY: continue
		var id := str(d.get("id", ""))
		var text := str(d.get("text", ""))
		if q != "":
			if not id.to_lower().contains(q) and not text.to_lower().contains(q):
				continue
		var preview := text.replace("\n", " ")
		if preview.length() > 40:
			preview = preview.substr(0, 40) + "..."
		dialogue_list.add_item("%s  |  %s" % [id, preview])
		# store id as metadata
		dialogue_list.set_item_metadata(dialogue_list.item_count - 1, id)

func _on_dialogue_selected(index: int) -> void:
	var id := str(dialogue_list.get_item_metadata(index))
	_focus_node(id)

func _focus_node(id: String) -> void:
	var node := graph.get_node_or_null(id)
	if node and node is GraphNode:
		graph.set_selected(node)
		graph.scroll_offset = (node as GraphNode).position_offset - Vector2(200, 200)

func _rebuild_graph() -> void:
	# Clear
	for c in graph.get_children():
		c.queue_free()
	graph.clear_connections()

	# Build nodes
	for d in db.dialogues:
		if typeof(d) != TYPE_DICTIONARY: continue
		var id := str(d.get("id", ""))
		if id == "": continue

		var gn := GraphNode.new()
		gn.name = id
		gn.title = id
		gn.resizable = true
		gn.draggable = true
		gn.size = Vector2(260, 160)
		gn.position_offset = Vector2(randi() % 600, randi() % 400)

		# small preview label
		var lbl := Label.new()
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.text = str(d.get("text", "")).strip_edges()
		lbl.custom_minimum_size = Vector2(220, 60)
		gn.add_child(lbl)

		# Add slots for options (RIGHT side ports)
		var opts: Array = d.get("options", [])
		for i in range(opts.size()):
			var opt := opts[i]
			var port_name := str(opt.get("text", "Option"))
			gn.set_slot(i, false, 0, Color(), true, 0, Color())
			gn.set_slot_title_right(i, port_name)

		graph.add_child(gn)

	# Build connections from nextID
	for d in db.dialogues:
		if typeof(d) != TYPE_DICTIONARY: continue
		var from_id := str(d.get("id", ""))
		var opts: Array = d.get("options", [])
		for i in range(opts.size()):
			var opt := opts[i]
			if typeof(opt) != TYPE_DICTIONARY: continue
			var to_id := DialogueDB._get_next_id(opt)
			if to_id != "" and db.by_id.has(to_id):
				graph.connect_node(from_id, i, to_id, 0)

func _on_graph_node_selected(node_name: String) -> void:
	selected_node_id = node_name
	selected_option_index = -1
	var d := db.by_id.get(node_name, null)
	if d == null:
		_build_inspector_placeholder()
		return
	_build_inspector_for_dialogue(d)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# Create connection
	graph.connect_node(from_node, from_port, to_node, to_port)

	# Update data
	var d := db.by_id.get(str(from_node), null)
	if d == null: return
	var opts: Array = d.get("options", [])
	if from_port < 0 or from_port >= opts.size(): return
	var opt := opts[from_port]
	if typeof(opt) != TYPE_DICTIONARY: return

	DialogueDB._set_next_id(opt, str(to_node))
	# Refresh inspector if this node is selected
	if selected_node_id == str(from_node):
		_build_inspector_for_dialogue(d)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph.disconnect_node(from_node, from_port, to_node, to_port)

	# If the opt points to that to_node, clear it
	var d := db.by_id.get(str(from_node), null)
	if d == null: return
	var opts: Array = d.get("options", [])
	if from_port < 0 or from_port >= opts.size(): return
	var opt := opts[from_port]
	if typeof(opt) != TYPE_DICTIONARY: return

	var cur := DialogueDB._get_next_id(opt)
	if cur == str(to_node):
		DialogueDB._set_next_id(opt, "")
	if selected_node_id == str(from_node):
		_build_inspector_for_dialogue(d)
		
func _queue_free_children(container: Node) -> void:
	for c in container.get_children():
		c.queue_free()
