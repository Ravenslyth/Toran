extends CharacterBody2D

@onready var detectionShape : CollisionShape2D = $DetectionArea/DetectionShape2D
@onready var actionBar = $ActionBar
 
@onready var tilemap : TileMap = get_parent().get_node("TileMap")
@export var trap_parent: Node

@export var team_data: TeamData
var team := []

@export var objUsed : object

var current_character_index := 0
var current_character: Node2D = null

var direction


var is_sprinting

var can_move = true

@export var inventory: Inventory
var itemToLoot = null


#----------------------INITIALISATION PLAYER-----------------------#

func _ready():
	actionBar.connect("action_completed", Callable(self, "_on_action_bar_complete"))
	
	if team_data.members.size() == 0:
		push_error("La team est vide.")
		return
		
	current_character_index = 0
	swap_to_character(current_character_index)

	#for char_data in team_data.members:
		#var instance := char_data.scene.instantiate()
		#instance.logic = char_data
		#team.append(instance)
	#swap_to_character(0)

	#enter_fight()

#--------------------END INITIALISATION PLAYER---------------------#

#------------------------PROCESS BY FRAME--------------------------#

func _physics_process(delta):
	if not can_move or current_character == null:
		if current_character:
			current_character.animated_sprite.play("idle")
		return

	if Input.is_action_just_pressed("swap_character"):
		current_character_index = (current_character_index + 1) % team_data.members.size()
		swap_to_character(current_character_index)

	var logic = team_data.members[current_character_index].logic
	var default_speed = logic.base_speed if logic.has_method("base_speed") else 200
	var sprint_speed = default_speed + 200

	if Input.is_action_pressed("sprint"):
		logic.base_speed = sprint_speed
		current_character.animated_sprite.speed_scale = 2.0
	else:
		logic.base_speed = default_speed
		current_character.animated_sprite.speed_scale = 1.0

	movementPlayer(logic.base_speed)  # appel avec la bonne vitesse

	current_character.play_movement_animation(direction)  # appel animation

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

func swap_to_character(index: int) -> void:
	# Supprime l'ancien personnage
	if current_character:
		current_character.queue_free()
	
	current_character_index = index
	var char_data: CharacterData = team_data.members[current_character_index]
	current_character = char_data.scene.instantiate()
	add_child(current_character)
	
#func swap_to_character(index: int):
	#if current_character:
		#current_character.queue_free()
	#
	#current_character_index = index
	#current_character = team[current_character_index]
	#add_child(current_character)
	#detectionShape.scale = current_character.logic.detection

#-------------------------END INTERACTION--------------------------#

 
#----------------------GET ID && COORD MAP-------------------------#

 
func get_current_tile_center_global_pos() -> Vector2:
	var local_pos = tilemap.to_local(current_character.global_position)
	var cell_coords = tilemap.local_to_map(local_pos)
	var cell_local_pos = tilemap.map_to_local(cell_coords)
	var cell_global_pos = tilemap.to_global(cell_local_pos)

 
	return cell_coords

	
#--------------------END GET ID && COORD MAP-----------------------#

#--------------------Signal Detection Player-----------------------#

func _on_detection_area_body_entered(body):
	if body.obj.lootable:
		itemToLoot = body

func _on_detection_area_body_exited(body):
	itemToLoot = null

#------------------END Signal Detection Player---------------------#

#-------------------Signal action bar Player-----------------------#

func _on_action_bar_complete():
	if objUsed:
		can_move = true
		objUsed.on_use(global_position, trap_parent, objUsed)
		objUsed.nbr -= 1
		if objUsed.nbr == 0:
			inventory.remove(objUsed)
			objUsed = null

#-----------------END Signal action bar Player---------------------# 

#------------------------enter in fight----------------------------# 

func enter_fight():
	var enemy_team_data : TeamData = preload("res://ressource/enemy/enemy_team_data.tres")
	
	
	GameState.save_player_data(
		team_data
	)
	GameState.save_enemy_data(
		enemy_team_data
	)
	
	var combat_scene = preload("res://scene/map/fight_Scene.tscn")
	get_tree().change_scene_to_packed(combat_scene)

