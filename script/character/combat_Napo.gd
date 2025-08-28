extends Node2D

signal IDLE_mode
signal MOVE_mode
signal DIRECTION_mode
signal ACTION_mode
signal END_mode

signal no_move_left
signal character_died(character_node: Node2D)

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

@export var character_logic: CharacterLogic
@export var map : TileMap
var menu_ref : Node = null
@export var listCharacter : Array
 
var tile_position: Vector2i
var offset = Vector2i(500, 500)  
var astargrid = AStarGrid2D.new()

var moves_short: int = 0
var moves_long: int = 0
var move_delay := 0.1  # délai en secondes entre chaque déplacement
var move_timer := 0.0

var is_moving := false

var original_tiles := {}  # Dictionnaire pour sauvegarder les tuiles d'origine
 
# Indique si la position de départ a déjà été initialisée
var has_initialized_tile_position := false  
var stop_moving = false

var previously_direction = null


func _ready():
	await get_tree().process_frame
	astargrid.size = Vector2i(1000, 1000) 
	astargrid.cell_size = Vector2i(32, 16)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	init_astar_blocked_tiles()
 

func is_on_upper_tile() -> bool:
	var tile_pos = map.local_to_map(position)
	var source_id = map.get_cell_source_id(1, tile_pos)  # Layer 1
	if source_id == -1:
		return false

	var tile_data = map.get_cell_tile_data(1, tile_pos)
	if tile_data == null:
		return false

	return tile_data.get_custom_data("height") == 1


func draw_attack_zone(zone: Array[Vector2i]):
	restore_all_tiles()
	for cell in zone:
		highlight_tile(cell, 1, 2)


func init_astar_blocked_tiles():
	var used_cells = map.get_used_cells(0)
	
	# 1. Bloquer les cellules définies comme non-walkables dans le TileMap
	for cell in used_cells:
		if not map.is_tile_walkable(cell):
			astargrid.set_point_solid(cell + offset, true)
	refresh_astar_blocked_tiles()
	
func refresh_astar_blocked_tiles():
	# Étape 1 : Réinitialiser toutes les cellules dynamiquement bloquées
	for character in listCharacter:
		var char_tile = map.local_to_map(character.position)
		astargrid.set_point_solid(char_tile + offset, false)
		
	
	# Étape 2 : Marquer les nouvelles positions occupées
	for character in listCharacter:
		var char_tile = map.local_to_map(character.position)
		astargrid.set_point_solid(char_tile + offset, true)

#Commande de déplacement 
func handle_move(delta):
	move_timer -= delta
	if move_timer > 0:
		return  # attendre que le timer atteigne 0
	
	if not has_initialized_tile_position:
		var start_pos = map.get_tile_coords_from_position(global_position)
		map.flag_positions.append(start_pos + offset)
		map.current_tile_position = start_pos
		has_initialized_tile_position = true
		map.update_cursor_position()
	
	 # position cible potentielle
	var radius = Vector2(character_logic.base_deplacment, character_logic.base_deplacment)
	var new_tile_pos = map.current_tile_position
	tile_position = map.get_tile_coords_from_position(global_position)
	var detection_zone = get_detection_zone(radius, 1,1)
	
	if Input.is_action_pressed("move_up"):
		new_tile_pos.y -= 1
	elif Input.is_action_pressed("move_down"):
		new_tile_pos.y += 1
	elif Input.is_action_pressed("move_left"):
		new_tile_pos.x -= 1
	elif Input.is_action_pressed("move_right"):
		new_tile_pos.x += 1
	elif Input.is_action_just_pressed("flag"):
		var pos_to_add = map.current_tile_position + offset
		if not map.flag_positions.has(pos_to_add):
			map.flag_positions.append(pos_to_add)
			map.place_flag_to_move(map.current_tile_position)
			await calculate_path_flag()
	elif Input.is_action_just_pressed("validation"):
		if (map.global_path.size() > 0 ):
			restore_all_tiles()
			refresh_astar_blocked_tiles()
			emit_signal("DIRECTION_mode")
			await move_Player(map.global_path)
			stop_moving = true
			map.Hide_cursor()
	elif Input.is_action_just_pressed("Canceled"):
		if(map.flag_positions.size() != 0):
			map.flag_positions.pop_back()
	if new_tile_pos != map.current_tile_position and map.is_tile_walkable(new_tile_pos) and detection_zone.has(new_tile_pos):
		map.current_tile_position = new_tile_pos
		map.update_cursor_position()
		move_timer = move_delay

#commande de choix de direction
func handle_direction(delta):
	if stop_moving:
		move_timer -= delta
		if move_timer > 0:
			return  # attendre que le timer atteigne 0
			
		if not has_initialized_tile_position:
			character_logic.direction = Vector2(0,-1)
			has_initialized_tile_position = true
		if Input.is_action_pressed("move_up"):
			character_logic.direction =Vector2(0,-1)
			play_idle_animation_iso(character_logic.direction)
		elif Input.is_action_pressed("move_down"):
			character_logic.direction =Vector2(-1,0)
			play_idle_animation_iso(character_logic.direction)
		elif Input.is_action_pressed("move_left"):
			character_logic.direction = Vector2(-1,-1)
			play_idle_animation_iso(character_logic.direction)
		elif Input.is_action_pressed("move_right"):
			character_logic.direction = Vector2(1,1)
			play_idle_animation_iso(character_logic.direction)
		elif Input.is_action_just_pressed("validation"):
			emit_signal("IDLE_mode")
			emit_signal("no_move_left")

func handle_action(delta):
	move_timer -= delta
	if move_timer > 0:
		return  # attendre que le timer atteigne 0
	
	if not has_initialized_tile_position:
		var start_pos = map.get_tile_coords_from_position(global_position)
		map.flag_positions.append(start_pos + offset)
		map.current_tile_position = start_pos
		has_initialized_tile_position = true
		map.update_cursor_position()
		
	var center = map.local_to_map(position)
	var zone = character_logic.equipment.main_weapon.attack_normal_zone(center)
	draw_attack_zone(zone)
		
	var new_tile_pos = map.current_tile_position
	if Input.is_action_pressed("move_up"):
		new_tile_pos.y -= 1
	elif Input.is_action_pressed("move_down"):
		new_tile_pos.y += 1
	elif Input.is_action_pressed("move_left"):
		new_tile_pos.x -= 1
	elif Input.is_action_pressed("move_right"):
		new_tile_pos.x += 1
	elif Input.is_action_just_pressed("validation"):
		var cursor_pointer = map.local_to_map(map.cursor.position)
		for character in listCharacter:
			var char_tile = map.local_to_map(character.position)
			if char_tile == cursor_pointer:
				restore_all_tiles()
				character_logic.equipment.main_weapon.attack_normal(character)
				emit_signal("IDLE_mode")
	if new_tile_pos != map.current_tile_position and map.is_tile_walkable(new_tile_pos) and zone.has(new_tile_pos):
		
		map.current_tile_position = new_tile_pos
		map.update_cursor_position()
		move_timer = move_delay
 
func calculate_path_flag():
	if map.flag_positions.size() < 2:
		print("choose a valid destination")
		return

	var full_path: Array[Vector2i] = []
	map.global_path.clear()

	for i in range(map.flag_positions.size() - 1):
		var path = astargrid.get_id_path(map.flag_positions[i], map.flag_positions[i + 1])
		if i > 0 and path.size() > 0:
			path.remove_at(0)  # Évite les doublons d'intersection
		full_path.append_array(path)
		map.global_path.append_array(path)  # Visuel cumulé sur la map

	var directions = []
	for i in range(full_path.size() - 1):
		var current = full_path[i]
		var next = full_path[i + 1]
		var direction = next - current
		directions.append(direction)

	for i in range(directions.size()):
		var dir = Vector2i(full_path[i + 1] - full_path[i])
		var x = dir.x
		var y = dir.y
		var current_pos = full_path[i] - offset

		if i > 0:
			var prev_dir = Vector2i(full_path[i] - full_path[i - 1])
			# Segments droits
			if x == 0 and y == -1:
				map.set_cell(1, current_pos, 1, Vector2(1, 24))  # Haut
			elif x == 0 and y == 1:
				map.set_cell(1, current_pos, 1, Vector2(1, 24))  # Bas
			elif x == 1 and y == 0:
				map.set_cell(1, current_pos, 1, Vector2(2, 24))  # Droite
			elif x == -1 and y == 0:
				map.set_cell(1, current_pos, 1, Vector2(2, 24))  # Gauche
			else:
				print("Point", i, "→ Direction inconnue:", dir)
			# Corners
			if prev_dir != dir:
				if prev_dir == Vector2i(0, -1) and dir == Vector2i(1, 0) or prev_dir == Vector2i(-1, 0) and dir == Vector2i(0, 1):
					map.set_cell(1, current_pos, 1, Vector2(1, 21))  # haut → droite
				elif prev_dir == Vector2i(1, 0) and dir == Vector2i(0, -1) or prev_dir == Vector2i(0, 1) and dir == Vector2i(-1, 0):
					map.set_cell(1, current_pos, 1, Vector2(2, 21))  # droite → haut
				elif prev_dir == Vector2i(0, -1) and dir == Vector2i(-1, 0) or prev_dir == Vector2i(1, 0) and dir == Vector2i(0, 1):
					map.set_cell(1, current_pos, 1, Vector2(3, 21))  # haut → gauche
				elif prev_dir == Vector2i(-1, 0) and dir == Vector2i(0, -1) or prev_dir == Vector2i(0, 1) and dir == Vector2i(1, 0):
					map.set_cell(1, current_pos, 1, Vector2(4, 21))  # gauche → haut

#déplace mon player sur d'un point A a un point B
func move_Player(path: Array[Vector2i]):
	map.Hide_cursor()
	var current_cell
	for i in range(1, path.size()):
		var prev_cell = path[i - 1] - offset
		current_cell = path[i] - offset

		# Sauter les étapes inutiles (par sécurité)
		if prev_cell == current_cell:
			continue
		
		var direction = current_cell - prev_cell
		var local_pos = map.map_to_local(current_cell)
		await play_movement_animation_iso(direction)
		var tween := get_tree().create_tween()
		tween.tween_property(self, "position", local_pos, 0.3)
		await tween.finished
	play_idle_animation_iso(Vector2(0,-1))
	map.clear_layer(1)
	map.global_path.clear()
	map.flag_positions.clear()
	map.flag_positions.append(current_cell + offset)
	for f in map.flag_instances:
		f.queue_free()
	map.flag_instances.clear()
	is_moving = true

#contrôle si mouvement long ou court
func controle_type_movement(path) :
	for i in range(1, path.size()):
			moves_short -= 1
			if(moves_short <= 0):
				moves_long -= 1
	if(moves_short >= 0):
		return true
	else:
		if(moves_long >= 0):
			return true
	print("plus de mouvement")
	return false

func play_movement_animation(direction: Vector2):
	if direction.y > 0 and direction.x < 0:
		animated_sprite.play("moveDownLeft")
	elif direction.y > 0 and direction.x > 0:
		animated_sprite.play("moveDownRight")
	elif direction.y < 0 and direction.x < 0:
		animated_sprite.play("moveUpLeft")
	elif direction.y < 0 and direction.x > 0:
		animated_sprite.play("moveUpRight")
	elif direction.y > 0:
		animated_sprite.play("moveDown")
	elif direction.y < 0:
		animated_sprite.play("moveUp")
	elif direction.x > 0:
		animated_sprite.play("moveRight")
	elif direction.x < 0:
		animated_sprite.play("moveLeft")
	elif direction.y == 0 and direction.x == 0:
		animated_sprite.play("idle")


func play_movement_animation_iso(direction: Vector2):
	if direction == Vector2.ZERO:
		animated_sprite.play("idle")
		return
	
	if direction.x == 0 and direction.y == -1:
		animated_sprite.play("moveUpRight")
	elif direction.x == 1 and direction.y == 0:
		animated_sprite.play("moveDownRight")
	elif direction.x == 0 and direction.y == 1:
		animated_sprite.play("moveDownLeft")
	elif direction.x == -1 and direction.y == 0:
		animated_sprite.play("moveUpLeft")
	elif direction.x == -1 and direction.y == -1:
		animated_sprite.play("moveUp")
	elif direction.x == 1 and direction.y == 1:
		animated_sprite.play("moveDown")
	elif direction.x == 1 and direction.y == -1:
		animated_sprite.play("moveRight")
	elif direction.x == -1 and direction.y == 1:
		animated_sprite.play("moveLeft")
	elif direction.x == 0 and direction.y ==0:
		animated_sprite.play("Idle")

func play_idle_animation_iso(direction: Vector2):
	if direction.x == 0 and direction.y == -1:
		animated_sprite.play("idleUpRight")
	elif direction.x == -1 and direction.y == 0:
		animated_sprite.play("idleDownLeft")
	elif direction.x == -1 and direction.y == -1:
		animated_sprite.play("idleUpLeft")
	elif direction.x == 1 and direction.y == 1:
		animated_sprite.play("idleDownRight")

# Detection around character with elliptical radius
func get_detection_zone(radius: Vector2, highlight_tile_id: int, atl_tile: int) -> Array[Vector2i]:
	restore_all_tiles()  # Restaure les anciennes tuiles avant de commencer
	original_tiles.clear()

	var center = tile_position
	var zone: Array[Vector2i] = []
	
	# Parcours de tous les offsets dans un rectangle englobant
	for y in range(-int(radius.y), int(radius.y) + 1):
		for x in range(-int(radius.x), int(radius.x) + 1):
			var offset = Vector2(x, y)

			# Formule d'ellipse normalisée : (x/rx)^2 + (y/ry)^2 <= 1
			var norm_x = offset.x / radius.x
			var norm_y = offset.y / radius.y
			if norm_x * norm_x + norm_y * norm_y <= 1.0:
				var cell = center + Vector2i(offset)
				if map.is_tile_walkable(cell):
					highlight_tile(cell, highlight_tile_id,atl_tile)
					zone.append(cell)
	return zone

#On affiche un highlight sur une cellule précise 
func highlight_tile(cell: Vector2i, new_tile_id: int, atl_tile: int):
	var old_id = map.get_cell_source_id(0, cell)
	var old_atlas = map.get_cell_atlas_coords(0, cell)
	original_tiles[cell] = { "id": old_id, "atlas": old_atlas }
	map.set_cell(0, cell, 0, old_atlas, atl_tile)  # source_id, atlas_coords, alternative_tile

 #On restaure les tuiles 
func restore_all_tiles():
	for cell in original_tiles.keys():
		var data = original_tiles[cell]
		map.set_cell(0, cell, data["id"], data["atlas"],0)

func death():
	if character_logic.current_hp <= 0:
		emit_signal("character_died", self)
		queue_free()
