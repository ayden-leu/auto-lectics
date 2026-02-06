@tool
extends Node3D
class_name DialogueOption

signal option_picked

enum HORIZONTAL_ALIGNMENT{
	left,
	center,
	right
}
enum VERTICAL_ALIGNMENT{
	top,
	center,
	bottom
}

@export var dummyThickness:float = 0.08
@export var labelPadding:Vector2 = Vector2(0.1, 0.1)
@export var horizontalAlignment:HORIZONTAL_ALIGNMENT = HORIZONTAL_ALIGNMENT.right
@export var verticalAlignment:VERTICAL_ALIGNMENT = VERTICAL_ALIGNMENT.top

@onready var label:Label3D = $TextLabel
@onready var hitbox:CollisionShape3D = $InteractionHitbox/CollisionShape3D
@onready var visualArea:CollisionShape3D = $InteractionHitbox/CollisionShape3D/VisualArea/CollisionShape3D
@onready var background:MeshInstance3D = $Background

var hitboxPadding:float = 0.05
var labelHeight:float = 0.0  # used externally
var goingToDie:bool = false

var text:String = "":
	set(value):
		text = value
		label.text = value
var nextDialogue:int = -1

func _ready() -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	#visible = false
	visible = false
	
func _process(_delta: float) -> void:
	# Only runs this code while the game is running
	if Engine.is_editor_hint():
		applySettings()

func spawn() -> void:
	await get_tree().create_timer(0.0001).timeout
	applySettings()
	
	if goingToDie:
		return
	
	visible = true
	hitbox.disabled = false

func applySettings() -> void:
	applyLabelSettings()
	applyBackgroundSettingsAy()

func applyLabelSettings() -> void:
	# TODO:  call after the configuration gets set up
	
	match horizontalAlignment:
		HORIZONTAL_ALIGNMENT.left:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			label.position.z = -labelPadding.x/2
		HORIZONTAL_ALIGNMENT.right:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			label.position.z = labelPadding.x/2
		HORIZONTAL_ALIGNMENT.center:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.position.z = 0
		_:
			printerr("Unhandled horizontal alignment: ", horizontalAlignment)
	
	match verticalAlignment:
		VERTICAL_ALIGNMENT.top:
			label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			label.position.y = -labelPadding.y/2
		VERTICAL_ALIGNMENT.bottom:
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			label.position.y = labelPadding.y/2
		VERTICAL_ALIGNMENT.center:
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.position.y = 0
		_:
			printerr("Unhandled vertical alignment: ", verticalAlignment)

func applyBackgroundSettingsAy() -> void:
	var labelSize:Vector3 = label.get_aabb().size
	
	background.mesh.size.x = dummyThickness
	background.mesh.size.y = labelSize.y + labelPadding.y
	background.mesh.size.z = labelSize.x + labelPadding.x
	
	match horizontalAlignment:
		HORIZONTAL_ALIGNMENT.left:
			background.position.z = -labelSize.x/2 + label.position.z
		HORIZONTAL_ALIGNMENT.right:
			background.position.z = labelSize.x/2 + label.position.z
		HORIZONTAL_ALIGNMENT.center:
			background.position.z = 0
		_:
			printerr("Unhandled horizontal alignment: ", horizontalAlignment)
	
	match verticalAlignment:
		VERTICAL_ALIGNMENT.top:
			#background.mesh.size.y = labelSize.y - label.position.y * 2
			background.position.y = -labelSize.y/2 + label.position.y
		VERTICAL_ALIGNMENT.bottom:
			#background.mesh.size.y = labelSize.y + label.position.y * 2
			background.position.y = labelSize.y/2 + label.position.y
		VERTICAL_ALIGNMENT.center:
			background.position.y = 0
		_:
			printerr("Unhandled vertical alignment: ", verticalAlignment)

	hitbox.shape.size = background.mesh.size + Vector3.ONE * hitboxPadding
	hitbox.position.y = background.position.y
	hitbox.position.z = background.position.z
	
	visualArea.shape.size = hitbox.shape.size
	
	labelHeight = hitbox.shape.size.y

func kill():
	goingToDie = true
	queue_free()

func _on_interaction() -> void:
	emit_signal("option_picked", nextDialogue)
