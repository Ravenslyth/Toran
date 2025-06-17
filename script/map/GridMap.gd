extends TileMap

@onready var line = $Line2D
@onready var cursor = $Marker2D
@onready var flag = preload("res://scene/Fight/flag.tscn")

# Position actuelle du curseur sur la grille (en coordonnées de tuile)
var current_tile_position: Vector2i
var flag_positions: Array[Vector2i] = []  # Tableau pour stocker les positions des flags
var flag_instances := []

var move_delay := 0.1  # délai en secondes entre chaque déplacement
var move_timer := 0.0

var moves_short: int = 0
var moves_long: int = 0
var test: bool 

var offset = Vector2i(500, 500)  
var astargrid = AStarGrid2D.new()

var global_path: Array[Vector2i] = []

# Vérifie si une tuile est marchable (en lisant la donnée personnalisée `is_walkable`)
func is_tile_walkable(coords: Vector2i) -> bool:
	var atlas_coords = get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return false  # Pas de tuile placée ici

	var source_id = get_cell_source_id(0, coords)
	 
	if not tile_set.has_source(source_id):
		return false

	var source = tile_set.get_source(source_id)
	if source is TileSetAtlasSource:
		var tile_data = source.get_tile_data(atlas_coords,0)
		if tile_data :
			var walkable = tile_data.get_custom_data("is_walkable")
			return tile_data.get_custom_data("is_walkable") == true
	return false

# Place une entité (personnage) sur une tuile spécifique
# `tile` : coordonnées de tuile
# `entity` : instance de personnage à placer
func place_entities_on_tile(tile: Vector2i, entity):
	var local_pos = map_to_local(tile)
	entity.global_position = to_global(local_pos)

# Met à jour la position du curseur visuel (Sprite2D) pour suivre la tuile actuelle
func update_cursor_position():
	var local_pos = map_to_local(current_tile_position)
	var tween = create_tween()
	tween.tween_property(cursor, "position", local_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if !cursor.visible:
		cursor.visible = true

# Cache le cursor
func Hide_cursor():
	cursor.visible = false

func get_tile_coords_from_position(world_pos: Vector2) -> Vector2i:
	var local_pos = to_local(world_pos)
	return local_to_map(local_pos)


#place un point de positionnement
func place_flag_to_move(current_tile_position):
	var flag_instance = flag.instantiate()
	flag_instance.position = map_to_local(current_tile_position)
	add_child(flag_instance)
	flag_instances.append(flag_instance)

func clear_path_layer():
	clear_layer(2)  # Nettoie toutes les tuiles du layer 1

