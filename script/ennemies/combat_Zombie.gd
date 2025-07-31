extends Node2D

signal IDLE_mode
signal MOVE_mode
signal DIRECTION_mode
signal ACTION_mode
signal END_mode

signal no_move_left
signal character_died(character_node: Node2D)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


@export var character_logic: CharacterLogic
@export var map: TileMap
@export var listCharacter : Array

var astargrid = AStarGrid2D.new()
var offset = Vector2i(500, 500)  

var characterDetected : Array
var is_moving := false
var tile_position: Vector2i
var original_tiles := {}  # Dictionnaire pour sauvegarder les tuiles d'origine
var path
var stop_moving = false

enum Action {
	DETECTION,
	TARGET,
	MOVE,
	ACTION,
	END
}

var target = null
var current_state: Action = Action.DETECTION
var pathToMove : Array
var state_in_progress := false

# Indique si la position de départ a déjà été initialisée
var has_initialized_tile_position := false  

func _ready():
	await get_tree().process_frame
	astargrid.size = Vector2i(1000, 1000) 
	astargrid.cell_size = Vector2i(32, 16)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	init_astar_blocked_tiles()
 
func play():
	if state_in_progress:
		return  # Ne rien faire si une action est déjà en cours

	state_in_progress = true  # Empêche d'autres appels le temps de finir l'action
	
	match current_state:
		Action.DETECTION:
			get_detection_character()
			if characterDetected:
				print("recherche de cible....")
				current_state = Action.TARGET
			else:
				print("retourne patrouiller....")
				restore_all_tiles()
				current_state = Action.END
			state_in_progress = false  # Action immédiate terminée
		Action.TARGET:
			print("Cibles trouvées !")
			print(calc_dist_target())
			print("Je vais focus ", target.name)
			current_state = Action.MOVE
			state_in_progress = false  # Action immédiate terminée
		Action.MOVE:
			await move_ennemy(map.global_path)
			refresh_astar_blocked_tiles()
			state_in_progress = false  # Fin de l'action asynchrone
			restore_all_tiles()
			current_state = Action.ACTION
		Action.ACTION:
			var center = map.local_to_map(position)
			var zone = attack_normal_zone(center)
			draw_attack_zone(zone)
			attack_normal(target)
			await animated_sprite.animation_finished
			give_damage()
			restore_all_tiles()
			state_in_progress = false  # Fin de l'action asynchrone
			current_state = Action.END
		Action.END:
			state_in_progress = false  # Fin de l'action asynchrone
			target = null
			emit_signal("END_mode")


#Detection around character
func get_detection_zone(radius: int, highlight_tile_id: int, atl_tile: int) -> Array[Vector2i]:
	restore_all_tiles()  # Restaure les anciennes tuiles avant de commencer
	original_tiles.clear()

	var center = tile_position
	var zone: Array[Vector2i] = []

	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var offset = Vector2i(x, y)
			if offset.length() <= radius:
				var cell = center + offset
				if map.is_tile_walkable(cell):
					highlight_tile(cell, highlight_tile_id,atl_tile)
					zone.append(cell)
	return zone

#Detection character 
func get_detection_character():
	characterDetected.clear()
	var radius = character_logic.RadiusDetection
	var detection_zone = get_detection_zone(radius,1,1)
	for character in listCharacter:
		var node_cell: Vector2i = map.local_to_map(character.position)
		if(detection_zone.has(node_cell) && character.character_logic.team != character_logic.team):
			characterDetected.append(character)

# Vérifie si une tuile est marchable (en lisant la donnée personnalisée `is_walkable`)
func is_tile_walkable(coords: Vector2i) -> bool:
	var atlas_coords = map.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return false  # Pas de tuile placée ici

	var source_id = map.get_cell_source_id(0, coords)
	 
	if not map.tile_set.has_source(source_id):
		return false

	var source = map.tile_set.get_source(source_id)
	if source is TileSetAtlasSource:
		var tile_data = source.get_tile_data(atlas_coords,0)
		if tile_data :
			var walkable = tile_data.get_custom_data("is_walkable")
			return tile_data.get_custom_data("is_walkable") == true
	return false

#bloque les tuiles qui ne sont pas marchable
func init_astar_blocked_tiles():
	var used_cells = map.get_used_cells(0)
	
	for cell in used_cells:
		if not is_tile_walkable(cell):
			astargrid.set_point_solid(cell + offset, true)
	
	refresh_astar_blocked_tiles()

func refresh_astar_blocked_tiles():
	# Étape 1 : Réinitialiser toutes les cellules dynamiquement bloquées
	for character in listCharacter:
		var prev_pos = map.get_tile_coords_from_position(character.position)
		astargrid.set_point_solid(prev_pos + offset, false)
	
	# Étape 2 : Marquer les nouvelles positions occupées
	for character in listCharacter:
		var current_pos = map.get_tile_coords_from_position(character.position)
		astargrid.set_point_solid(current_pos + offset, true)


#calclule la distance entre un point A et un point B
func get_cell_distance_astar(start: Vector2i, end: Vector2i) :
	astargrid.update()  # Assure-toi que la grille est à jour
	path = astargrid.get_id_path(start + offset, end + offset)
	return path 

#Recherche la cible la plus proche
func calc_dist_target():
	var my_cell: Vector2i = map.local_to_map(position)
	var min_distance := INF  # Une très grande valeur initiale
	for character in characterDetected:
		var node_cell: Vector2i = map.local_to_map(character.position)
		var chem = get_cell_distance_astar(my_cell, node_cell)
		var distance = chem.size()
		if distance != -1 and distance < min_distance:
			map.global_path.clear()
			map.global_path.append_array(path)
			target = character
			min_distance = distance
	# Si aucune distance valide trouvée, on peut retourner -1
	if min_distance == INF:
		return null
	return target

func move_ennemy(path: Array[Vector2i]):
	var current_cell
	for i in range(1, path.size()-1):
		var prev_cell = path[i - 1] - offset
		current_cell = path[i] - offset

		# Sauter les étapes inutiles (par sécurité)
		if prev_cell == current_cell:
			continue
		
		var direction = current_cell - prev_cell
		var local_pos = map.map_to_local(current_cell)
		play_movement_animation_iso(direction)
		var tween := get_tree().create_tween()
		tween.tween_property(self, "position", local_pos, 0.3)
		await tween.finished
	play_movement_animation_iso(Vector2(-1,0))

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
		map.set_cell(0, cell, data["id"], data["atlas"])

func play_movement_animation_iso(direction: Vector2):
	if direction.x == 0 and direction.y == -1:
		animated_sprite.play("moveUpRight")
	elif direction.x == 1 and direction.y == 0:
		animated_sprite.play("moveDownRight")
	elif direction.x == 0 and direction.y == 1:
		animated_sprite.play("moveDownLeft")
	elif direction.x == -1 and direction.y == 0:
		animated_sprite.play("moveUpLeft")
	elif direction.x == 0 and direction.y ==0:
		animated_sprite.play("Idle")

func death():
	if character_logic.current_hp <= 0:
		emit_signal("character_died", self)
		await get_tree().process_frame
		print("tata")
		call_deferred("queue_free")  # Laisse le signal se propager avant suppression


func attack_normal_zone(center: Vector2i) -> Array[Vector2i]:
	var zone: Array[Vector2i] = []
	zone.append(center)
	# Gauche / Droite
	for i in range(1, int(character_logic.range.x) + 1):
		zone.append(center + Vector2i.LEFT * i)
		zone.append(center + Vector2i.RIGHT * i)
		
	# Haut / Bas
	for i in range(1, int(character_logic.range.y) + 1):
		zone.append(center + Vector2i.UP * i)
		zone.append(center + Vector2i.DOWN * i)
		
	return zone

func draw_attack_zone(zone: Array[Vector2i]):
	restore_all_tiles()
	for cell in zone:
		highlight_tile(cell, 1, 2)


func attack_normal(target : Node2D):
	animated_sprite.play("croc")


func give_damage():
	target.character_logic.current_hp -= character_logic.attack
	target.death()
 
