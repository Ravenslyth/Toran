extends CharacterBody2D

@onready var napo_scene = preload("res://scene/character/Napo.tscn")
@onready var grano_scene = preload("res://scene/character/Grano.tscn")
@onready var detectionShape : CollisionShape2D = $DetectionArea/DetectionShape2D
@onready var tilemap := get_parent().get_node("TileMap")

<<<<<<< Updated upstream
var current_character : Node2D = null
=======
@export var team_data: TeamData
@export var inventory : Inventory

var team := []
var current_character_index := 0
var current_character: Node2D = null

>>>>>>> Stashed changes
var direction

var object_current_loot : Area2D = null
 

#----------------------INITIALISATION PLAYER-----------------------#

func _ready():
	#0002
	swap_character("Napo")

#--------------------END INITIALISATION PLAYER---------------------#

#------------------------PROCESS BY FRAME--------------------------#

func _physics_process(delta):
	
	var tile_id = get_current_tile_atlas_coords()
	print(tile_id)
	
	if Input.is_action_just_pressed("loot"):
<<<<<<< Updated upstream
		if object_current_loot:

			#0003
			add_item_inventory(object_current_loot)
=======
		if current_character.logic.object_current_loot:
			current_character.logic.object_current_loot.collect(inventory)
>>>>>>> Stashed changes
	if Input.is_action_just_pressed("swap_character"):
		if current_character.name == "Napo":
			#0002
			swap_character("Grano")
		else:
			#0002
			swap_character("Napo")
	
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
func swap_character(character_name:String):
	if current_character:
		current_character.queue_free()
	
	if character_name == "Napo":
		current_character = napo_scene.instantiate()
	elif character_name == "Grano":
		current_character = grano_scene.instantiate()
		
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

<<<<<<< Updated upstream
#-----------------------ADD ITEM INVENTORY-------------------------#
#0003
func add_item_inventory(object_current):
	if current_character.logic.inventory.size() >= current_character.logic.MAX_INVENTORY_SIZE:
		print("To much object .....")
		return
		
	print("Its could be useful ...")
	#current_character.logic.inventory.append(object_current.name)
	object_current.queue_free()
	
	if object_current == object_current_loot:
		object_current_loot = null

	print(current_character.logic.inventory)
#---------------------END ADD ITEM INVENTORY-----------------------#
=======
func get_current_tile_atlas_coords() -> Vector2i:
	var local_pos = tilemap.to_local(current_character.global_position)
	var cell_coords = tilemap.local_to_map(local_pos)
	var layer = 0  # la plupart du temps, 0
	var atlas_coords = tilemap.get_cell_atlas_coords(layer, cell_coords)
	return atlas_coords

>>>>>>> Stashed changes
