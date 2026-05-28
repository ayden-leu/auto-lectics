extends Node3D

# feel free to remove sections you're not using
# ------------------------------------------------
# signals
# ------------------------------------------------

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# ------------------------------------------------
@onready var globalPlayer:AudioStreamPlayer = %Global
@onready var positionalPlayer:AudioStreamPlayer3D = %Positional
@onready var idField:OptionButton = %IdField
@onready var camera:Camera3D = %Camera

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------
func _ready() -> void:
	FR_MenuManager.disable()
	FR_WindowManager.disable()
	CursorHandler.setDefault("shown")
	CursorHandler.showNuclear()

	_loadOptionButtonOptions(
		idField,
		_getFoldersInPath(AudioLoader.STORAGE_PATH)
	)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_forward"):
		camera.position.z -= 0.1
	elif Input.is_action_pressed("move_backward"):
		camera.position.z += 0.1
	elif Input.is_action_pressed("move_left"):
		camera.position.x -= 0.1
	elif Input.is_action_pressed("move_right"):
		camera.position.x += 0.1

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------

# ------------------------------------------------
# functions only referenced inside this script
# ------------------------------------------------
func _getFoldersInPath(path:String) -> Array[String]:
	var tempDirAccess:DirAccess = DirAccess.open(path)
	if not tempDirAccess:
		printerr("Directory [", path, "] does not exist.")
	tempDirAccess.list_dir_begin()

	var directories:Array[String]
	var entryName:String = tempDirAccess.get_next()
	while entryName != "":
		if tempDirAccess.current_is_dir():
			directories.push_back(entryName)
		entryName = tempDirAccess.get_next()

	directories.sort()
	return directories

func _loadOptionButtonOptions(button:OptionButton, options:Array[String]) -> void:
	for option in options:
		button.add_item(option)
	button.selected = 0

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------
func _on_load_pressed() -> void:
	AudioLoader.clearAudioRandomizer(globalPlayer.stream)
	AudioLoader.clearAudioRandomizer(positionalPlayer.stream)

	var sfxID:String = idField.get_item_text(idField.selected)
	print("Loading SFX ID: [", sfxID, "]")
	var resultOne:Error = AudioLoader.loadSfxFromId(sfxID, globalPlayer.stream)
	var resultTwo:Error = AudioLoader.loadSfxFromId(sfxID, positionalPlayer.stream)

	if resultOne == Error.OK and resultTwo == Error.OK:
		print("Loading successful.")

func _on_play_global_pressed() -> void:
	globalPlayer.play()

func _on_play_positional_pressed() -> void:
	positionalPlayer.play()

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
