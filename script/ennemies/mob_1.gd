extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


@export var character_logic: CharacterLogic
@export var map: TileMap
@export var listCharacter : Array

var astargrid = AStarGrid2D.new()
var offset = Vector2i(500, 500)  

var characterDetected : Array

var tile_position: Vector2i
var original_tiles := {}  # Dictionnaire pour sauvegarder les tuiles d'origine
var path

enum Action {
	DETECTION,
	TARGET,
	MOVE,
	ACTION
}

var target = null
var current_state: Action = Action.DETECTION

func _ready():
	await get_tree().process_frame
	astargrid.size = Vector2i(1000, 1000) 
	astargrid.cell_size = Vector2i(32, 16)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	init_astar_blocked_tiles()

func play():
	match current_state:
		Action.DETECTION:
			get_detection_character()
			if characterDetected:
				print("recherche de cible....")
				current_state = Action.TARGET
			else:
				print("retourne patrouiller....")
		Action.TARGET:
			print("Cibles trouvé ! ")
			calc_dist_target()
			print("Je vais focuus " , target.name)
		Action.MOVE:
			print("titi")


#Detection around character
func get_detection_zone(radius: int, highlight_tile_id: int) -> Array[Vector2i]:
	restore_all_tiles()  # Restaure les anciennes tuiles avant de commencer
	original_tiles.clear()

	var center = tile_position
	var zone: Array[Vector2i] = []

	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var offset = Vector2i(x, y)
			if offset.length() <= radius:
				var cell = center + offset
				highlight_tile(cell, highlight_tile_id)
				zone.append(cell)
	return zone

#Detection character 
func get_detection_character():
	var radius = character_logic.RadiusDetection
	var detection_zone = get_detection_zone(radius,1)
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

#calclule la distance entre un point A et un point B
func get_cell_distance_astar(start: Vector2i, end: Vector2i) -> int:
	astargrid.update()  # Assure-toi que la grille est à jour
	path = astargrid.get_id_path(start + offset, end + offset)
	print(path)
	if path.size() < 2:
		return -1
	return path.size() - 1  


#Recherche la cible la plus proche
func calc_dist_target():
	var my_cell: Vector2i = map.local_to_map(position)
	var min_distance := INF  # Une très grande valeur initiale
	for character in characterDetected:
		var node_cell: Vector2i = map.local_to_map(character.position)
		var distance = get_cell_distance_astar(my_cell, node_cell)
		if distance != -1 and distance < min_distance:
			target = character
			min_distance = distance
	# Si aucune distance valide trouvée, on peut retourner -1
	if min_distance == INF:
		return null
	return target

#On affiche un highlight sur une cellule précise 
func highlight_tile(cell: Vector2i, new_tile_id: int):
	var old_id = map.get_cell_source_id(0, cell)
	var old_atlas = map.get_cell_atlas_coords(0, cell)
	original_tiles[cell] = { "id": old_id, "atlas": old_atlas }
	map.set_cell(0, cell, 0, old_atlas, 1)  # source_id, atlas_coords, alternative_tile

 #On restaure les tuiles 
func restore_all_tiles():
	for cell in original_tiles.keys():
		var data = original_tiles[cell]
		map.set_cell(0, cell, data["id"], data["atlas"])

func move():
	pass

