extends Node2D

#signal no_move_left

@onready var camera = $Camera2D
@onready var map = $TileMap
var ui : Node = null

# Liste des unités dans la file d'attente des tours (ordre d'action)
@export var turn_queue := []

@export var current_character: Node2D = null

# Index du personnage dont c'est actuellement le tour
@export var current_index: int = 0


# Enumération des états possibles du système de tour
enum Action {
	IDLE,
	DETECTION,
	MOVE,
	DIRECTION,
	ACTION,
	END
}

var current_action = Action.IDLE
var enemy_turn_started := false

var no_move_left_round = false
# Ajoute une unité à la file d'attente des tours
# Trie ensuite la file par agilité décroissante (plus rapide = joue plus tôt)
func add_to_turn_queue(unit):
	turn_queue.append(unit)
	turn_queue.sort_custom(Callable(self, "_sort_by_agility"))

# Fonction de tri personnalisée utilisée dans `sort_custom`
# Retourne vrai si l'unité `a` est plus rapide que l'unité `b`
func _sort_by_agility(a, b) -> bool:
	return a.character_logic.agility > b.character_logic.agility

func _process(delta):
	if current_character.character_logic.team == "Player":
		match current_action:
			Action.MOVE:
				current_character.handle_move(delta)
			Action.DIRECTION:
				current_character.handle_direction(delta)
			Action.ACTION:
				current_character.handle_action(delta)
	else:
		current_character.play()
			
# Démarre le tour du personnage actuellement sélectionné dans la queue
func start_turn():
	map.global_path.clear()
	map.flag_positions.clear()
	no_move_left_round = false
	current_character = turn_queue[current_index]
	current_character.is_moving = false
	current_character.stop_moving = true
	camera.swap(current_character)
	ui.lifePlayer.max_value = current_character.character_logic.max_hp
	ui.lifePlayer.value = current_character.character_logic.current_hp
	ui.iconMainWeapon.texture = current_character.character_logic.equipment.main_weapon.icon
	ui.textMainWeapon.text = current_character.character_logic.equipment.main_weapon.name
	current_character.listCharacter = turn_queue
	current_character.character_logic.set_outline_progress(0.8,current_character.animated_sprite)
	var local_pos = map.local_to_map(current_character.position)
	current_character.tile_position = local_pos

# Termine le tour actuel et passe à l’unité suivante
func end_turn():
	current_character.has_initialized_tile_position = false
	current_character.character_logic.set_outline_progress(0,current_character.animated_sprite)
	current_index = (current_index + 1) % turn_queue.size()
	current_action = Action.IDLE
	map.Hide_cursor()
	start_turn()

func _on_IDLE_mode():
	ui.visible = true
	map.Hide_cursor()
	current_character.is_moving = false
	current_action = Action.IDLE

func _on_MOVE_mode():
	current_character.restore_all_tiles()
	current_character.has_initialized_tile_position = false
	map.update_cursor_position()
	current_action = Action.MOVE
	current_character.is_moving = true
	
func _on_DIRECTION_mode():
	current_character.restore_all_tiles()
	current_character.has_initialized_tile_position = false
	current_action = Action.DIRECTION
	current_character.is_moving = true

func _on_no_move_left():
	no_move_left_round = true
	
func _on_ACTION_mode():
	current_character.restore_all_tiles()
	current_character.has_initialized_tile_position = false
	map.update_cursor_position()
	current_action = Action.ACTION

func _on_END_mode():
	end_turn()
	current_action = Action.END

func _on_character_died(character_node):
	turn_queue.erase(character_node)
	turn_queue = turn_queue.filter(func(c): return is_instance_valid(c))
	print("tutu")
