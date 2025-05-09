extends CharacterBody2D

@onready var napo_scene = preload("res://scene/character/Napo.tscn")
@onready var grano_scene = preload("res://scene/character/Grano.tscn")
@onready var detectionShape : CollisionShape2D = $DetectionArea/DetectionShape2D

@export var team_data: TeamData
var team := []
var current_character_index := 0
var current_character: Node2D = null

var direction

#----------------------INITIALISATION PLAYER-----------------------#

func _ready():
	for char_data in team_data.members:
		team.append(char_data.scene)
	#0002
	swap_to_character(0)
	 

#--------------------END INITIALISATION PLAYER---------------------#

#------------------------PROCESS BY FRAME--------------------------#

func _physics_process(delta):
	if Input.is_action_just_pressed("loot"):
		if current_character.logic.object_current_loot:
			#0003
			current_character.logic.add_item_inventory(current_character.logic.object_current_loot)
	if Input.is_action_just_pressed("swap_character"):
		current_character_index = (current_character_index + 1) % team.size()
		#0002
		swap_to_character(current_character_index)
	#if 
	
	if current_character:
		var speed = current_character.logic.get_speed()
		#0001
		movementPlayer(speed)
		current_character.logic.play_movement_animation(direction,current_character.animated_sprite)

#-----------------------END PROCESS BY FRAME------------------------#

#-------------------------MOVEMENT PLAYER---------------------------#
#0001
func movementPlayer(SPEED):
	direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	velocity = direction * SPEED
	
	move_and_slide()


#-----------------------END MOVEMENT PLAYER------------------------#

#---------------------------INTERACTION----------------------------#

#0002
func swap_to_character(index: int):
	if current_character:
		current_character.queue_free()
	
	current_character_index = index
	current_character = team[current_character_index].instantiate()
	add_child(current_character)
	detectionShape.scale = current_character.logic.detection

#-------------------------END INTERACTION--------------------------#

#------------------------DETECTION OBJECT--------------------------#

func _on_detection_area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	current_character.logic.object_current_loot = area
	print("A  " + area.obj.name + " ??")

func _on_detection_area_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if is_instance_valid(area):
		if area == current_character.logic.object_current_loot :
			print("Maybe another time ....")
			current_character.logic.object_current_loot = null

#--------------------END DETECTION OBJECT--------------------------#
