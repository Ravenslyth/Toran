extends CharacterBody2D

@onready var detectionShape : CollisionShape2D = $DetectionArea/DetectionShape2D
 
@onready var tilemap := get_parent().get_node("TileMap")

@export var team_data: TeamData
var team := []

var current_character : Node2D = null
var current_character_index := 0

var is_sprinting
var direction
var can_move = true

@export var inventory: Inventory

#----------------------INITIALISATION PLAYER-----------------------#

func _ready():
	for char_data in team_data.members:
		team.append(char_data.scene)
	
	swap_to_character(0)

#--------------------END INITIALISATION PLAYER---------------------#

#------------------------PROCESS BY FRAME--------------------------#

func _physics_process(delta):
	if can_move:
		if current_character:
			var default_speed = current_character.logic.default_speed   
			var sprint_speed = default_speed + 200
			
			if Input.is_action_just_pressed("swap_character"):
				current_character_index = (current_character_index + 1) % team.size()
				swap_to_character(current_character_index)
		
		 # ------------------------ Movement ---------------------- #
		
			if Input.is_action_pressed("sprint"):
				current_character.logic.base_speed = sprint_speed
				current_character.animated_sprite.speed_scale = 2.0
			else:
				current_character.logic.base_speed  = default_speed
				current_character.animated_sprite.speed_scale = 1.0

			movementPlayer(current_character.logic.base_speed )
			current_character.logic.play_movement_animation(direction,current_character.animated_sprite)
	else:
		if current_character:
			current_character.animated_sprite.play("idle")
#-----------------------END PROCESS BY FRAME------------------------#

#-------------------------MOVEMENT PLAYER---------------------------#

func movementPlayer(SPEED):
	direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	velocity = direction * SPEED
	
	move_and_slide()

#-----------------------END MOVEMENT PLAYER------------------------#

#---------------------------INTERACTION----------------------------#

func swap_to_character(index: int):
	if current_character:
		current_character.queue_free()
	
	current_character_index = index
	current_character = team[current_character_index].instantiate()
	add_child(current_character)
	detectionShape.scale = current_character.logic.detection

#-------------------------END INTERACTION--------------------------#

 
#----------------------GET ID && COORD MAP-------------------------#

func get_current_tile_atlas_coords() -> Vector2i:
	var local_pos = tilemap.to_local(current_character.global_position)
	var cell_coords = tilemap.local_to_map(local_pos)
	var layer = 0  # la plupart du temps, 0
	var atlas_coords = tilemap.get_cell_atlas_coords(layer, cell_coords)
	return atlas_coords
	
#--------------------END GET ID && COORD MAP-----------------------#



