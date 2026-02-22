extends Control

const DialogueDB = preload("res://addons/dialogue_generator/dialogue_db.gd")
const DialoguePathUtils = preload("res://addons/dialogue_generator/path_utils.gd")

var db := DialogueDB.new()
var npc_name: String = "NPC_Test2"
var json_path: String = ""
var dialogues: Array = [] # Array[Dictionary] 但为了兼容你DB里的函数这里不强类型

# ----------------------------
# UI refs - basic
# ----------------------------
var log_box: TextEdit
var preview_box: TextEdit

var npc_edit: LineEdit
var file_edit: LineEdit

var dialogue_id_edit: LineEdit
var dialogue_text_edit: LineEdit
var dialogue_type_opt: OptionButton
var dialogue_mode_opt: OptionButton

var option_index_spin: SpinBox
var option_text_edit: LineEdit
var option_type_opt: OptionButton
var option_next_edit: LineEdit

# ----------------------------
# UI refs - Dialogue advanced
# ----------------------------
var dlg_font: LineEdit
var dlg_write_speed: OptionButton
var dlg_write_speed_custom: SpinBox
var dlg_next_fail: LineEdit
var dlg_sfx_spawn: LineEdit
var dlg_sfx_text: LineEdit
var dlg_theme: LineEdit
var dlg_p_spawn: LineEdit
var dlg_p_text: LineEdit
var dlg_p_ambient: LineEdit

# ----------------------------
# UI refs - Option advanced
# ----------------------------
var opt_prereq: LineEdit
var opt_font: LineEdit
var opt_write_speed: OptionButton
var opt_write_speed_custom: SpinBox
var opt_sfx_spawn: LineEdit
var opt_sfx_text: LineEdit
var opt_theme: LineEdit
var opt_p_spawn: LineEdit
var opt_p_text: LineEdit
var opt_p_ambient: LineEdit
var opt_spawn_delay: SpinBox
var opt_lifetime: SpinBox


func _ready() -> void:
	_build_ui()
	_refresh_paths()
	_update_preview()


func _open_options_editor() -> void:
	var did := dialogue_id_edit.text.strip_edges()
	if did == "":
		_log("Please enter Dialogue ID first.\n")
		return

	var d := db.find_dialogue(dialogues, did)
	if d.is_empty():
		_log("Dialogue not found: %s\n" % did)
		return

	# 打开窗口，传入引用，窗口内修改会直接写回 d["options"]
	var win := OptionEditorWindow.new(
		db,
		d,
		func(): _update_preview(),  # on_changed
		func(): _save_file()        # on_save (writes json files)
	)
	add_child(win)
	win.popup_centered(win.size)
# =========================================================
# UI BUILD
# =========================================================
func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.size_flags_horizontal = SIZE_EXPAND_FILL
	root.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(root)

	# ---------- File row ----------
	var file_row := HBoxContainer.new()
	root.add_child(file_row)

	file_row.add_child(_mk_label("NPC:", 50))

	npc_edit = LineEdit.new()
	npc_edit.text = npc_name
	npc_edit.custom_minimum_size.x = 160
	npc_edit.text_changed.connect(func(_t): _refresh_paths())
	file_row.add_child(npc_edit)

	file_row.add_child(_mk_label("JSON path:", 80))

	file_edit = LineEdit.new()
	file_edit.editable = false
	file_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	file_row.add_child(file_edit)

	var btn_new := Button.new()
	btn_new.text = "New"
	btn_new.pressed.connect(_new_file)
	file_row.add_child(btn_new)

	var btn_load := Button.new()
	btn_load.text = "Load"
	btn_load.pressed.connect(_load_file)
	file_row.add_child(btn_load)

	var btn_save := Button.new()
	btn_save.text = "Save"
	btn_save.pressed.connect(_save_file)
	file_row.add_child(btn_save)

	var btn_validate := Button.new()
	btn_validate.text = "Validate"
	btn_validate.pressed.connect(_validate_now)
	file_row.add_child(btn_validate)

	# ---------- Dialogue row ----------
	var drow := HBoxContainer.new()
	root.add_child(drow)

	drow.add_child(_mk_label("Dialogue ID:", 90))

	dialogue_id_edit = LineEdit.new()
	dialogue_id_edit.placeholder_text = "D001"
	dialogue_id_edit.custom_minimum_size.x = 120
	drow.add_child(dialogue_id_edit)

	drow.add_child(_mk_label("Text:", 40))

	dialogue_text_edit = LineEdit.new()
	dialogue_text_edit.placeholder_text = "Dialogue text"
	dialogue_text_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	drow.add_child(dialogue_text_edit)

	drow.add_child(_mk_label("Type:", 45))
	dialogue_type_opt = OptionButton.new()
	for t in ["Neutral", "Happy", "Angry", "Confused", "Sad"]:
		dialogue_type_opt.add_item(t)
	drow.add_child(dialogue_type_opt)

	drow.add_child(_mk_label("Mode:", 50))
	dialogue_mode_opt = OptionButton.new()
	for m in ["Normal", "Hectic"]:
		dialogue_mode_opt.add_item(m)
	drow.add_child(dialogue_mode_opt)

	var btn_add_d := Button.new()
	btn_add_d.text = "Add/Update Dialogue"
	btn_add_d.pressed.connect(_add_update_dialogue)
	drow.add_child(btn_add_d)

	var btn_del_d := Button.new()
	btn_del_d.text = "Delete Dialogue"
	btn_del_d.pressed.connect(_delete_dialogue)
	drow.add_child(btn_del_d)
	
	var btn_opts := Button.new()
	btn_opts.text = "Options..."
	btn_opts.pressed.connect(_open_options_editor)
	drow.add_child(btn_opts)

	# ---------- Option row ----------
	var orow := HBoxContainer.new()
	root.add_child(orow)

	orow.add_child(_mk_label("Option idx:", 80))
	option_index_spin = SpinBox.new()
	option_index_spin.min_value = 0
	option_index_spin.step = 1
	option_index_spin.custom_minimum_size.x = 80
	orow.add_child(option_index_spin)

	orow.add_child(_mk_label("Opt text:", 70))
	option_text_edit = LineEdit.new()
	option_text_edit.placeholder_text = "Option text"
	option_text_edit.custom_minimum_size.x = 260
	orow.add_child(option_text_edit)

	orow.add_child(_mk_label("Opt type:", 70))
	option_type_opt = OptionButton.new()
	for t in ["Positive", "Neutral", "Negative"]:
		option_type_opt.add_item(t)
	orow.add_child(option_type_opt)

	orow.add_child(_mk_label("nextID:", 55))
	option_next_edit = LineEdit.new()
	option_next_edit.placeholder_text = "D002"
	option_next_edit.custom_minimum_size.x = 120
	orow.add_child(option_next_edit)

	var btn_set_opt := Button.new()
	btn_set_opt.text = "Add/Update Option"
	btn_set_opt.pressed.connect(_add_update_option)
	orow.add_child(btn_set_opt)

	var btn_del_opt := Button.new()
	btn_del_opt.text = "Delete Option"
	btn_del_opt.pressed.connect(_delete_option)
	orow.add_child(btn_del_opt)

	# ===== Dialogue Advanced Panel =====
	var dlg_adv := VBoxContainer.new()
	root.add_child(dlg_adv)

	var dlg_adv_title := Label.new()
	dlg_adv_title.text = "Dialogue Advanced"
	dlg_adv_title.add_theme_font_size_override("font_size", 16)
	dlg_adv.add_child(dlg_adv_title)

	dlg_font = _row_lineedit(dlg_adv, "font", "default")
	dlg_next_fail = _row_lineedit(dlg_adv, "Next Hectic Failure ID", "")
	dlg_theme = _row_lineedit(dlg_adv, "Background Theme", "default")

	dlg_write_speed = _row_option(dlg_adv, "Write Speed", ["slow", "medium", "fast"])
	dlg_write_speed_custom = _row_spin_int(dlg_adv, "Write Speed Custom", -1, -1, 999)

	dlg_sfx_spawn = _row_lineedit(dlg_adv, "sfx spawn", "default")
	dlg_sfx_text = _row_lineedit(dlg_adv, "sfx text", "default")

	dlg_p_spawn = _row_lineedit(dlg_adv, "particles spawn", "none")
	dlg_p_text = _row_lineedit(dlg_adv, "particles text", "none")
	dlg_p_ambient = _row_lineedit(dlg_adv, "particles ambient", "none")

	var btn_load_dlg := Button.new()
	btn_load_dlg.text = "Load Dialogue Fields From Current ID"
	btn_load_dlg.pressed.connect(_load_dialogue_fields_from_current)
	dlg_adv.add_child(btn_load_dlg)

	# ===== Option Advanced Panel =====
	var opt_adv := VBoxContainer.new()
	root.add_child(opt_adv)

	var opt_adv_title := Label.new()
	opt_adv_title.text = "Option Advanced"
	opt_adv_title.add_theme_font_size_override("font_size", 16)
	opt_adv.add_child(opt_adv_title)

	opt_prereq = _row_lineedit(opt_adv, "prerequest (comma separated)", "")
	opt_font = _row_lineedit(opt_adv, "font", "inherit")
	opt_theme = _row_lineedit(opt_adv, "backgroundTheme", "inherit")

	opt_write_speed = _row_option(opt_adv, "writeSpeed", ["inherit", "slow", "medium", "fast"])
	opt_write_speed_custom = _row_spin_int(opt_adv, "writeSpeedCustom", -1, -1, 999)

	opt_sfx_spawn = _row_lineedit(opt_adv, "sfx.spawn", "none")
	opt_sfx_text = _row_lineedit(opt_adv, "sfx.text", "inherit")

	opt_p_spawn = _row_lineedit(opt_adv, "particles.spawn.texture", "none")
	opt_p_text = _row_lineedit(opt_adv, "particles.text.texture", "inherit")
	opt_p_ambient = _row_lineedit(opt_adv, "particles.ambient.texture", "inherit")

	opt_spawn_delay = _row_spin_float(opt_adv, "spawnDelay", 0.5, 0.0, 999.0, 0.1)
	opt_lifetime = _row_spin_int(opt_adv, "lifetime", -1, -1, 999999)

	var btn_load_opt := Button.new()
	btn_load_opt.text = "Load Option Fields From Current"
	btn_load_opt.pressed.connect(_load_option_fields_from_current)
	opt_adv.add_child(btn_load_opt)

	# ---------- Log + Preview ----------
	log_box = TextEdit.new()
	log_box.editable = false
	log_box.custom_minimum_size.y = 120
	root.add_child(log_box)

	preview_box = TextEdit.new()
	preview_box.editable = false
	preview_box.size_flags_vertical = SIZE_EXPAND_FILL
	root.add_child(preview_box)

	_log("Ready. Use New/Load, then edit dialogues/options and Save.\n")


# =========================================================
# UI helpers
# =========================================================
func _mk_label(text: String, min_w: float) -> Label:
	var l := Label.new()
	l.text = text
	l.custom_minimum_size.x = min_w
	return l

func _row_lineedit(parent: VBoxContainer, label: String, placeholder: String) -> LineEdit:
	var row := HBoxContainer.new()
	parent.add_child(row)
	row.add_child(_mk_label(label, 220))
	var e := LineEdit.new()
	e.placeholder_text = placeholder
	e.size_flags_horizontal = SIZE_EXPAND_FILL
	row.add_child(e)
	return e

func _row_option(parent: VBoxContainer, label: String, items: Array[String]) -> OptionButton:
	var row := HBoxContainer.new()
	parent.add_child(row)
	row.add_child(_mk_label(label, 220))
	var ob := OptionButton.new()
	for it in items:
		ob.add_item(it)
	row.add_child(ob)
	return ob

func _row_spin_int(parent: VBoxContainer, label: String, val: int, minv: int, maxv: int) -> SpinBox:
	var row := HBoxContainer.new()
	parent.add_child(row)
	row.add_child(_mk_label(label, 220))
	var sp := SpinBox.new()
	sp.min_value = minv
	sp.max_value = maxv
	sp.step = 1
	sp.value = val
	row.add_child(sp)
	return sp

func _row_spin_float(parent: VBoxContainer, label: String, val: float, minv: float, maxv: float, stepv: float) -> SpinBox:
	var row := HBoxContainer.new()
	parent.add_child(row)
	row.add_child(_mk_label(label, 220))
	var sp := SpinBox.new()
	sp.min_value = minv
	sp.max_value = maxv
	sp.step = stepv
	sp.value = val
	row.add_child(sp)
	return sp

func _select_option_text(ob: OptionButton, text: String) -> void:
	for i in range(ob.item_count):
		if ob.get_item_text(i) == text:
			ob.select(i)
			return
	ob.select(0)

func _autofill_ui_after_load() -> void:
	if dialogues.is_empty():
		_log("No dialogues found to autofill.\n")
		return

	# Sort dialogues by id for stable behavior
	dialogues.sort_custom(func(a, b):
		return str(a.get("id", "")) < str(b.get("id", ""))
	)

	# Pick first dialogue
	var first: Dictionary = dialogues[0]
	var did := str(first.get("id", ""))
	dialogue_id_edit.text = did

	# Fill dialogue fields (basic + advanced)
	_load_dialogue_fields_from_current()

	# Options: set idx=0 and fill if exists
	db.ensure_list(first, "options")
	var opts: Array = first.get("options", [])
	if opts.size() > 0:
		option_index_spin.value = 0
		_load_option_fields_from_current()
	else:
		# Clear option fields if no options
		option_text_edit.text = ""
		option_next_edit.text = ""
		_select_option_text(option_type_opt, "Neutral")
		opt_prereq.text = ""
		opt_font.text = "inherit"
		_select_option_text(opt_write_speed, "inherit")
		opt_write_speed_custom.value = -1
		opt_theme.text = "inherit"
		opt_spawn_delay.value = 0.5
		opt_lifetime.value = -1
		opt_sfx_spawn.text = "none"
		opt_sfx_text.text = "inherit"
		opt_p_spawn.text = "none"
		opt_p_text.text = "inherit"
		opt_p_ambient.text = "inherit"

	_log("Autofilled UI from loaded data.\n")
# =========================================================
# Path / File
# =========================================================
func _refresh_paths() -> void:
	npc_name = npc_edit.text.strip_edges()
	json_path = DialoguePathUtils.get_npc_dir(npc_name)  # pure path
	file_edit.text = json_path

func _new_file() -> void:
	DialoguePathUtils.ensure_npc_dir(npc_name) # create folder only here
	dialogues = []
	_log("Created new empty dialogue list.\n")
	_update_preview()

func _load_file() -> void:
	dialogues.clear()

	var npc_dir := DialoguePathUtils.get_npc_dir(npc_name)
	var dir := DirAccess.open(npc_dir)

	if dir == null:
		_log("NPC folder not found.\n")
		return

	dir.list_dir_begin()
	while true:
		var fname := dir.get_next()
		if fname == "":
			break
		if fname.ends_with(".json"):
			var full_path := npc_dir.path_join(fname)
			var arr := db.load_or_create(full_path)
			if arr.size() > 0:
				dialogues.append(arr[0]) # 每个文件只存一个 dialogue
	dir.list_dir_end()

	_log("Loaded %d dialogues from folder.\n" % dialogues.size())
	_update_preview()
	_autofill_ui_after_load()

func _save_file() -> void:
	var npc_dir := DialoguePathUtils.ensure_npc_dir(npc_name) # create folder only here

	for d in dialogues:
		if typeof(d) != TYPE_DICTIONARY:
			continue
		var did := str(d.get("id", "")).strip_edges()
		if did == "":
			continue

		var path := DialoguePathUtils.get_dialogue_path(npc_name, did)
		var cleaned := db.clean_defaults_dialogue(d)
		db.save(path, [cleaned])

	_log("Saved %d dialogues to folder %s\n" % [dialogues.size(), npc_dir])
	_update_preview()
	
func _validate_now() -> void:
	var errs := db.validate(dialogues)
	if errs.size() == 0:
		_log("[PASS] Validation OK\n")
	else:
		_log("[FAIL] Validation errors:\n")
		for e in errs:
			_log("  - %s\n" % e)


# =========================================================
# Dialogue operations
# =========================================================
func _add_update_dialogue() -> void:
	var did := dialogue_id_edit.text.strip_edges()
	if did == "":
		_log("Dialogue ID is empty.\n")
		return

	var dtype := dialogue_type_opt.get_item_text(dialogue_type_opt.selected)
	var dmode := dialogue_mode_opt.get_item_text(dialogue_mode_opt.selected)
	var text := dialogue_text_edit.text

	var d := db.find_dialogue(dialogues, did)
	if d.is_empty():
		var ok := db.add_dialogue(dialogues, did, text, dtype, dmode)
		if not ok:
			_log("Failed to add dialogue (duplicate?) %s\n" % did)
			return
		d = db.find_dialogue(dialogues, did)
		_log("Added dialogue %s\n" % did)
	else:
		_log("Updated dialogue %s\n" % did)

	# 统一写入（新建/更新都执行）
	d["text"] = text
	d["type"] = dtype
	d["mode"] = dmode

	d["font"] = dlg_font.text
	d["writeSpeed"] = dlg_write_speed.get_item_text(dlg_write_speed.selected)
	d["writeSpeedCustom"] = int(dlg_write_speed_custom.value)
	d["nextOnHecticFailureID"] = dlg_next_fail.text
	d["backgroundTheme"] = dlg_theme.text

	d["sfx"] = {
		"spawn": dlg_sfx_spawn.text,
		"text": dlg_sfx_text.text,
	}

	d["particles"] = {
		"spawn": {"texture": dlg_p_spawn.text},
		"text": {"texture": dlg_p_text.text},
		"ambient": {"texture": dlg_p_ambient.text},
	}

	db.ensure_list(d, "options")
	_update_preview()

func _delete_dialogue() -> void:
	var did := dialogue_id_edit.text.strip_edges()
	if did == "":
		_log("Dialogue ID is empty.\n")
		return

	for i in range(dialogues.size() - 1, -1, -1):
		var d = dialogues[i]
		if typeof(d) == TYPE_DICTIONARY and str(d.get("id", "")) == did:
			dialogues.remove_at(i)
			_log("Deleted dialogue %s\n" % did)
			_update_preview()
			return

	_log("Dialogue not found: %s\n" % did)


# =========================================================
# Option operations
# =========================================================
func _add_update_option() -> void:
	var did := dialogue_id_edit.text.strip_edges()
	if did == "":
		_log("Need Dialogue ID to edit options.\n")
		return

	var d := db.find_dialogue(dialogues, did)
	if d.is_empty():
		_log("Dialogue not found: %s\n" % did)
		return

	db.ensure_list(d, "options")
	var opts: Array = d["options"]

	var idx := int(option_index_spin.value)
	var otext := option_text_edit.text
	var otype := option_type_opt.get_item_text(option_type_opt.selected)
	var next_id := option_next_edit.text.strip_edges()

	# Expand list if needed by appending defaults
	while opts.size() <= idx:
		db.add_option_to_dialogue(d, "New Option", "Neutral", "")
		opts = d["options"]

	var opt := opts.get(idx)
	if typeof(opt) != TYPE_DICTIONARY:
		_log("Option %d is not a Dictionary.\n" % idx)
		return

	# basic
	opt["text"] = otext
	opt["type"] = otype
	opt["nextID"] = next_id

	# prerequest: "a,b,c" -> ["a","b","c"]
	var parts := opt_prereq.text.split(",", false)
	var prereq: Array = []
	for p in parts:
		var s := p.strip_edges()
		if s != "":
			prereq.append(s)

	# advanced
	opt["prerequest"] = prereq
	opt["font"] = opt_font.text
	opt["writeSpeed"] = opt_write_speed.get_item_text(opt_write_speed.selected)
	opt["writeSpeedCustom"] = int(opt_write_speed_custom.value)
	opt["backgroundTheme"] = opt_theme.text
	opt["spawnDelay"] = float(opt_spawn_delay.value)
	opt["lifetime"] = int(opt_lifetime.value)

	opt["sfx"] = {
		"spawn": opt_sfx_spawn.text,
		"text": opt_sfx_text.text,
	}

	opt["particles"] = {
		"spawn": {"texture": opt_p_spawn.text},
		"text": {"texture": opt_p_text.text},
		"ambient": {"texture": opt_p_ambient.text},
	}

	_log("Updated option %d for dialogue %s\n" % [idx, did])
	_update_preview()

func _delete_option() -> void:
	var did := dialogue_id_edit.text.strip_edges()
	if did == "":
		_log("Need Dialogue ID.\n")
		return

	var d := db.find_dialogue(dialogues, did)
	if d.is_empty():
		_log("Dialogue not found: %s\n" % did)
		return

	db.ensure_list(d, "options")
	var opts: Array = d["options"]
	var idx := int(option_index_spin.value)

	if idx < 0 or idx >= opts.size():
		_log("Option idx out of range.\n")
		return

	opts.remove_at(idx)
	_log("Deleted option %d from dialogue %s\n" % [idx, did])
	_update_preview()


# =========================================================
# Load fields into UI (from current ID / option idx)
# =========================================================
func _load_dialogue_fields_from_current() -> void:
	var did := dialogue_id_edit.text.strip_edges()
	var d := db.find_dialogue(dialogues, did)
	if d.is_empty():
		_log("Dialogue not found: %s\n" % did)
		return

	var rd := db.resolve_defaults_dialogue(d)

	# basic fields也帮你填一下（更省事）
	dialogue_text_edit.text = str(rd.get("text", ""))
	_select_option_text(dialogue_type_opt, str(rd.get("type", "Neutral")))
	_select_option_text(dialogue_mode_opt, str(rd.get("mode", "Normal")))

	# advanced
	dlg_font.text = str(rd.get("font", "default"))
	_select_option_text(dlg_write_speed, str(rd.get("writeSpeed", "medium")))
	dlg_write_speed_custom.value = int(rd.get("writeSpeedCustom", -1))
	dlg_next_fail.text = str(rd.get("nextOnHecticFailureID", ""))
	dlg_theme.text = str(rd.get("backgroundTheme", "default"))

	var sfx: Dictionary = rd.get("sfx", {})
	dlg_sfx_spawn.text = str(sfx.get("spawn", "default"))
	dlg_sfx_text.text = str(sfx.get("text", "default"))

	var particles: Dictionary = rd.get("particles", {})
	dlg_p_spawn.text = str(particles.get("spawn", {}).get("texture", "none"))
	dlg_p_text.text = str(particles.get("text", {}).get("texture", "none"))
	dlg_p_ambient.text = str(particles.get("ambient", {}).get("texture", "none"))

	_log("Loaded dialogue fields for %s\n" % did)

func _load_option_fields_from_current() -> void:
	var did := dialogue_id_edit.text.strip_edges()
	var d := db.find_dialogue(dialogues, did)
	if d.is_empty():
		_log("Dialogue not found: %s\n" % did)
		return

	db.ensure_list(d, "options")
	var opts: Array = d["options"]
	var idx := int(option_index_spin.value)

	if idx < 0 or idx >= opts.size():
		_log("Option idx out of range.\n")
		return

	var opt: Dictionary = opts[idx]
	var ro := db.resolve_defaults_option(opt, d)

	# basic
	option_text_edit.text = str(ro.get("text", ""))
	_select_option_text(option_type_opt, str(ro.get("type", "Neutral")))
	option_next_edit.text = str(ro.get("nextID", ""))

	# advanced
	var prereq_arr: Array = ro.get("prerequest", [])
	opt_prereq.text = ",".join(prereq_arr)

	opt_font.text = str(ro.get("font", "inherit"))
	_select_option_text(opt_write_speed, str(ro.get("writeSpeed", "inherit")))
	opt_write_speed_custom.value = int(ro.get("writeSpeedCustom", -1))
	opt_theme.text = str(ro.get("backgroundTheme", "inherit"))
	opt_spawn_delay.value = float(ro.get("spawnDelay", 0.5))
	opt_lifetime.value = int(ro.get("lifetime", -1))

	var sfx: Dictionary = ro.get("sfx", {})
	opt_sfx_spawn.text = str(sfx.get("spawn", "none"))
	opt_sfx_text.text = str(sfx.get("text", "inherit"))

	var particles: Dictionary = ro.get("particles", {})
	opt_p_spawn.text = str(particles.get("spawn", {}).get("texture", "none"))
	opt_p_text.text = str(particles.get("text", {}).get("texture", "inherit"))
	opt_p_ambient.text = str(particles.get("ambient", {}).get("texture", "inherit"))

	_log("Loaded option fields for %s[%d]\n" % [did, idx])


# =========================================================
# Preview / Log
# =========================================================
func _update_preview() -> void:
	# 显示“最终保存的样子”（clean defaults 后）
	var out: Array = []
	for d in dialogues:
		if typeof(d) == TYPE_DICTIONARY:
			out.append(db.clean_defaults_dialogue(d))

	var json_text := JSON.stringify(out, "\t", false)
	if preview_box:
		preview_box.text = "Dialogues 预览（%d 条）\n\n%s" % [out.size(), json_text]
		preview_box.scroll_vertical = 0

func _log(s: String) -> void:
	if log_box:
		log_box.text += s
		log_box.scroll_vertical = 999999

class OptionEditorWindow:
	extends Window

	var db
	var dialogue_ref: Dictionary
	var on_changed: Callable
	var on_save: Callable  # NEW: save-to-disk callback from main

	var list: ItemList
	var txt: LineEdit
	var typ: OptionButton
	var next_id: LineEdit

	# advanced
	var prereq: LineEdit
	var font: LineEdit
	var write_speed: OptionButton
	var write_speed_custom: SpinBox
	var theme_edit: LineEdit
	var sfx_spawn: LineEdit
	var sfx_text: LineEdit
	var p_spawn: LineEdit
	var p_text: LineEdit
	var p_ambient: LineEdit
	var spawn_delay: SpinBox
	var lifetime: SpinBox

	var current_idx: int = -1
	func _clear_fields_for_empty() -> void:
		txt.text = ""
		_select_option_text(typ, "Neutral")
		next_id.text = ""

		prereq.text = ""
		font.text = "inherit"
		_select_option_text(write_speed, "inherit")
		write_speed_custom.value = -1
		theme_edit.text = "inherit"

		sfx_spawn.text = "none"
		sfx_text.text = "inherit"
		p_spawn.text = "none"
		p_text.text = "inherit"
		p_ambient.text = "inherit"
		spawn_delay.value = 0.5
		lifetime.value = -1
		
	func _init(_db, _dialogue_ref: Dictionary, _on_changed: Callable, _on_save: Callable) -> void:
		db = _db
		dialogue_ref = _dialogue_ref
		on_changed = _on_changed
		on_save = _on_save

	func _ready() -> void:
		title = "Option Editor - " + str(dialogue_ref.get("id", ""))
		min_size = Vector2i(600, 600)

		# Make window closable via the X button
		close_requested.connect(func(): queue_free())

		db.ensure_list(dialogue_ref, "options")
#
		#var outer := CenterContainer.new()
		#outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		#add_child(outer)

		var root := HBoxContainer.new()
		root.custom_minimum_size = Vector2(500, 600)
		root.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		root.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		add_child(root)
		
		# -------- Left: list + buttons --------
		var left := VBoxContainer.new()
		left.custom_minimum_size.x = 260
		root.add_child(left)

		list = ItemList.new()
		list.size_flags_vertical = Control.SIZE_EXPAND_FILL
		list.select_mode = ItemList.SELECT_SINGLE
		list.item_selected.connect(_on_select)
		list.item_clicked.connect(func(index: int, _pos: Vector2, _btn: int):
			_on_select(index)
		)
		left.add_child(list)
		
		var btn_add_bottom := Button.new()
		btn_add_bottom.text = "Add option"
		btn_add_bottom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_add_bottom.pressed.connect(_add_option)
		left.add_child(btn_add_bottom)
		
		var left_btns := HBoxContainer.new()
		left.add_child(left_btns)

		#var btn_add := Button.new()
		#btn_add.text = "Add"
		#btn_add.pressed.connect(_add_option)
		#left_btns.add_child(btn_add)

		var btn_del := Button.new()
		btn_del.text = "Delete option"
		btn_del.pressed.connect(_delete_option)
		left_btns.add_child(btn_del)

		var btn_save := Button.new()
		btn_save.text = "Save"
		btn_save.pressed.connect(func():
			_apply_to_current()
			if on_save.is_valid():
				on_save.call()
		)
		left_btns.add_child(btn_save)

		var btn_close := Button.new()
		btn_close.text = "Close"
		btn_close.pressed.connect(func(): queue_free())
		left_btns.add_child(btn_close)

		var scroll := ScrollContainer.new()
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		root.add_child(scroll)
		# -------- Right: fields --------
		var right := VBoxContainer.new()
		right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		right.size_flags_vertical = Control.SIZE_EXPAND_FILL
		root.add_child(right)

		txt = _row_lineedit(right, "text", "")
		typ = _row_option(right, "type", ["Positive", "Neutral", "Negative"])
		next_id = _row_lineedit(right, "nextID", "")

		prereq = _row_lineedit(right, "prerequest (comma separated)", "")
		font = _row_lineedit(right, "font", "inherit")
		write_speed = _row_option(right, "writeSpeed", ["inherit", "slow", "medium", "fast"])
		write_speed_custom = _row_spin_int(right, "writeSpeedCustom", -1, -1, 999)
		theme_edit = _row_lineedit(right, "backgroundTheme", "inherit")

		sfx_spawn = _row_lineedit(right, "sfx.spawn", "none")
		sfx_text  = _row_lineedit(right, "sfx.text", "inherit")

		p_spawn   = _row_lineedit(right, "particles.spawn.texture", "none")
		p_text    = _row_lineedit(right, "particles.text.texture", "inherit")
		p_ambient = _row_lineedit(right, "particles.ambient.texture", "inherit")

		# IMPORTANT: you had vars but didn't actually create these widgets before
		spawn_delay = _row_spin_float(right, "spawnDelay", 0.5, 0.0, 999.0, 0.1)
		lifetime    = _row_spin_int(right, "lifetime", -1, -1, 999999)

		var btn_apply := Button.new()
		btn_apply.text = "Apply Changes"
		btn_apply.pressed.connect(_apply_to_current)
		right.add_child(btn_apply)

		_refresh_list()
		if list.item_count > 0:
			list.select(0)
			_on_select(0)
		else:
			current_idx = -1
			_clear_fields_for_empty()
			
	func _options() -> Array:
		return dialogue_ref.get("options", [])

	func _refresh_list() -> void:
		list.clear()
		var opts: Array = _options()
		for i in range(opts.size()):
			var o = opts[i]
			var t := ""
			if typeof(o) == TYPE_DICTIONARY:
				t = str(o.get("text", ""))
			list.add_item("%02d: %s" % [i, t])

	func _on_select(index: int) -> void:
		# Auto-apply current edits when switching
		if current_idx != -1 and current_idx != index:
			_apply_to_current()

		current_idx = index
		var opts: Array = _options()
		if index < 0 or index >= opts.size():
			return

		var o = opts[index]
		if typeof(o) != TYPE_DICTIONARY:
			return

		var ro: Dictionary = db.resolve_defaults_option(o, dialogue_ref)

		txt.text = str(ro.get("text", ""))
		_select_option_text(typ, str(ro.get("type", "Neutral")))
		next_id.text = str(ro.get("nextID", ""))

		prereq.text = ",".join(ro.get("prerequest", []))
		font.text = str(ro.get("font", "inherit"))
		_select_option_text(write_speed, str(ro.get("writeSpeed", "inherit")))
		write_speed_custom.value = int(ro.get("writeSpeedCustom", -1))
		theme_edit.text = str(ro.get("backgroundTheme", "inherit"))

		var sfx: Dictionary = ro.get("sfx", {})
		sfx_spawn.text = str(sfx.get("spawn", "none"))
		sfx_text.text  = str(sfx.get("text", "inherit"))

		var particles: Dictionary = ro.get("particles", {})
		p_spawn.text = str(particles.get("spawn", {}).get("texture", "none"))
		p_text.text  = str(particles.get("text", {}).get("texture", "inherit"))
		p_ambient.text = str(particles.get("ambient", {}).get("texture", "inherit"))

		spawn_delay.value = float(ro.get("spawnDelay", 0.5))
		lifetime.value = int(ro.get("lifetime", -1))

	func _apply_to_current() -> void:
		var opts: Array = _options()
		if current_idx < 0 or current_idx >= opts.size():
			return
		var o = opts[current_idx]
		if typeof(o) != TYPE_DICTIONARY:
			return

		o["text"] = txt.text
		o["type"] = typ.get_item_text(typ.selected)
		o["nextID"] = next_id.text.strip_edges()

		var parts := prereq.text.split(",", false)
		var arr: Array = []
		for p in parts:
			var s := p.strip_edges()
			if s != "":
				arr.append(s)
		o["prerequest"] = arr

		o["font"] = font.text
		o["writeSpeed"] = write_speed.get_item_text(write_speed.selected)
		o["writeSpeedCustom"] = int(write_speed_custom.value)
		o["backgroundTheme"] = theme_edit.text
		o["spawnDelay"] = float(spawn_delay.value)
		o["lifetime"] = int(lifetime.value)

		o["sfx"] = {
			"spawn": sfx_spawn.text,
			"text": sfx_text.text,
		}
		o["particles"] = {
			"spawn": {"texture": p_spawn.text},
			"text": {"texture": p_text.text},
			"ambient": {"texture": p_ambient.text},
		}

		_refresh_list()
		list.select(current_idx)

		if on_changed.is_valid():
			on_changed.call()

	func _add_option() -> void:
	# if currently editing a valid option, write it back first
		_apply_to_current()

		db.add_option_to_dialogue(dialogue_ref, "New Option", "Neutral", "")
		_refresh_list()

		var idx := list.item_count - 1
		list.select(idx)
		_on_select(idx)

		if on_changed.is_valid():
			on_changed.call()

	func _delete_option() -> void:
		var opts: Array = _options()
		if current_idx < 0 or current_idx >= opts.size():
			return
		opts.remove_at(current_idx)
		current_idx = clamp(current_idx, 0, opts.size() - 1)
		_refresh_list()
		if list.item_count > 0:
			list.select(current_idx)
			_on_select(current_idx)
		if on_changed.is_valid():
			on_changed.call()

	# --- small UI helpers inside the window ---
	func _row_lineedit(parent: VBoxContainer, label: String, placeholder: String) -> LineEdit:
		var row := HBoxContainer.new()
		parent.add_child(row)
		var l := Label.new()
		l.text = label
		l.custom_minimum_size.x = 220
		row.add_child(l)
		var e := LineEdit.new()
		e.placeholder_text = placeholder
		e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(e)
		return e

	func _row_option(parent: VBoxContainer, label: String, items: Array[String]) -> OptionButton:
		var row := HBoxContainer.new()
		parent.add_child(row)
		var l := Label.new()
		l.text = label
		l.custom_minimum_size.x = 220
		row.add_child(l)
		var ob := OptionButton.new()
		for it in items:
			ob.add_item(it)
		row.add_child(ob)
		return ob

	func _row_spin_int(parent: VBoxContainer, label: String, val: int, minv: int, maxv: int) -> SpinBox:
		var row := HBoxContainer.new()
		parent.add_child(row)
		var l := Label.new()
		l.text = label
		l.custom_minimum_size.x = 220
		row.add_child(l)
		var sp := SpinBox.new()
		sp.min_value = minv
		sp.max_value = maxv
		sp.step = 1
		sp.value = val
		row.add_child(sp)
		return sp

	func _row_spin_float(parent: VBoxContainer, label: String, val: float, minv: float, maxv: float, stepv: float) -> SpinBox:
		var row := HBoxContainer.new()
		parent.add_child(row)
		var l := Label.new()
		l.text = label
		l.custom_minimum_size.x = 220
		row.add_child(l)
		var sp := SpinBox.new()
		sp.min_value = minv
		sp.max_value = maxv
		sp.step = stepv
		sp.value = val
		row.add_child(sp)
		return sp

	func _select_option_text(ob: OptionButton, text: String) -> void:
		for i in range(ob.item_count):
			if ob.get_item_text(i) == text:
				ob.select(i)
				return
		ob.select(0)
