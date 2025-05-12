extends CharacterBody2D

@onready var detectionShape : CollisionShape2D = $DetectionArea/DetectionShape2D
@onready var inventory_gui =  $Camera2D/CanvasLayer/InventoryGui
@onready var tilemap := get_parent().get_node("TileMap")

@export var team_data: TeamData
var team := []

@export var inventory : Inventory
var object_current_loot : Area2D = null

var current_character : Node2D = null
var current_character_index := 0

var direction
var can_move = true

#----------------------INITIALISATION PLAYER-----------------------#

func _ready():
	inventory_gui.inventory_opened.connect(_on_inventory_opened)
	inventory_gui.inventory_closed.connect(_on_inventory_closed)
	
	for char_data in team_data.members:
		team.append(char_data.scene)
	#0002
	swap_to_character(0)

#--------------------END INITIALISATION PLAYER---------------------#

#------------------------PROCESS BY FRAME--------------------------#

func _physics_process(delta):
	if can_move:
		if Input.is_action_just_pressed("loot"):
			if object_current_loot:
				object_current_loot.collect(inventory)

		if Input.is_action_just_pressed("swap_character"):
			current_character_index = (current_character_index + 1) % team.size()
			swap_to_character(current_character_index)
		
		if current_character:
			var speed = current_character.logic.get_speed()
			movementPlayer(speed)
			current_character.logic.play_movement_animation(direction,current_character.animated_sprite)
	else:
		if current_character:
			current_character.animated_sprite.play("idle")
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
	object_current_loot = area
	print("A  " + area.obj.name + " ??")

func _on_detection_area_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if is_instance_valid(area):
		if area == object_current_loot :
			print("Maybe another time ....")
			object_current_loot = null

#--------------------END DETECTION OBJECT--------------------------#

 

 
#----------------------GET ID && COORD MAP-------------------------#

func get_current_tile_atlas_coords() -> Vector2i:
	var local_pos = tilemap.to_local(current_character.global_position)
	var cell_coords = tilemap.local_to_map(local_pos)
	var layer = 0  # la plupart du temps, 0
	var atlas_coords = tilemap.get_cell_atlas_coords(layer, cell_coords)
	return atlas_coords
	
#--------------------END GET ID && COORD MAP-----------------------#

func _on_inventory_opened():
	can_move = false  

func _on_inventory_closed():
	can_move = true   
