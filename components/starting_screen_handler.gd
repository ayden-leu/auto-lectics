
extends Node
class_name StartingScreenForRealThisTime

@export var amIOnTheTitleScreen = true

@onready var flavorText = %FlavorTextLabel
@onready var startText = %StartTextLabel
@onready var background = %Background

var isStartTextGoing = false
var didAudioPlay = false

func _ready() -> void:
	flavorText.visible_ratio = 0
	startText.visible_characters = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start_game"):
		amIOnTheTitleScreen = false
		startText.visible = false
		background.visible = false
		get_tree().change_scene_to_file("res://world/spring_week_3_playtest.tscn")
							
	elif event.is_action_pressed("close_game_from_title_screen"):
		if amIOnTheTitleScreen == true and startText.visible == true: 
			get_tree().quit()

func _updateFlavorText() -> void: 
	
	flavorText.visible_ratio += 0.001
	
	if flavorText.visible_ratio >= 1 and didAudioPlay == false:
		%StartUp.play()

		await get_tree().create_timer(1.0).timeout
		didAudioPlay = true
		flavorText.visible = false
		startText.visible = true
		isStartTextGoing = true

func _updateStartText() -> void: 
	startText.visible_characters += 1

func _process(delta: float) -> void:
	_updateFlavorText()
	if isStartTextGoing == true:
		_updateStartText()
