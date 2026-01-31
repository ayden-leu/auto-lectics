@tool
extends CharacterBody3D
class_name Player

const SPEED:float = 5.0
const JUMP_VELOCITY:float = 4.5

@onready var cameraAnchor:Marker3D = %CameraAnchor
@onready var interactionRaycast:RayCast3D = $RayCast3D

func _process(_delta: float) -> void:
	# Dev-ing stuff
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _physics_process(delta: float) -> void:
	# Makes sure the code only runs while the game is running
	if Engine.is_editor_hint():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func jump() -> void:	
	velocity.y = JUMP_VELOCITY

# Modifies velocity so `move_and_slide()` can move the player
func handleDirectionInput(direction:Vector3) -> void:
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

# Rotates the player when the mouse moves horizontally
func _onMouseMoved(distanceMoved:Vector2) -> void:
	#print(name + ": mouse moved")
	rotation_degrees.y += -distanceMoved.x
	interactionRaycast.rotation_degrees.x -= -distanceMoved.y

func _onInteractPressed() -> void:
	#print(name + ": interact pressed")
	# TODO: make a better way to get the NPC we're acting with
	# 		making assumptions about the node hierarchy isn't good
	if interactionRaycast.get_collider() is Area3D:
		interactionRaycast.get_collider().get_parent()._onInteraction()



# Dev-ing stuff
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:Array[String] = []
	var numInputHandlers:int = get_tree().get_node_count_in_group("InputHandler")
	
	if numInputHandlers < 1:
		warnings.push_back(
			"There isn't a InputHandler node, so the player won't be able to the player character.
			Consider adding an InputHandler node from the helpers folder.
		")
	elif numInputHandlers > 1:
		warnings.push_back(
			"There are too many InputHandler nodes.
			This won't crash the game, but it may lead to unexpected behavior.
		")
	
	return warnings
