extends CharacterBody2D

@onready var napo_scene = preload("res://scene/character/Napo.tscn")
@onready var grano_scene = preload("res://scene/character/Grano.tscn")
@onready var detectionShape : CollisionShape2D = $CollisionShape2D

var current_character : Node2D = null
var direction

func _ready():
	spawn_character("Napo")

func _physics_process(delta):
	if Input.is_action_just_pressed("swap_character"):
		if current_character.name == "Napo":
			spawn_character("Grano")
		else:
			spawn_character("Napo")
	
	if current_character:
		var speed = current_character.logic.get_speed()
		movementPlayer(speed)
		current_character.logic.play_movement_animation(direction,current_character.animated_sprite)

#-------------------------MOVEMENT PLAYER---------------------------#

#-----movement function                                             
func movementPlayer(SPEED):
	direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	velocity = direction * SPEED
	
	move_and_slide()

#-----------------------END MOVEMENT PLAYER------------------------#

#---------------------------INTERACTION----------------------------#

#-----Swap character
func spawn_character(character_name:String):
	if current_character:
		current_character.queue_free()
	
	if character_name == "Napo":
		current_character = napo_scene.instantiate()
	elif character_name == "Grano":
		current_character = grano_scene.instantiate()
		
	add_child(current_character)
	detectionShape.scale = current_character.logic.detection
	
#-------------------------END INTERACTION--------------------------#


func _on_collision_shape_2d_tree_entered():
	print("tutu")
