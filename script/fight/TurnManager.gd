class_name TurnManager
extends Node2D

var turn_order := []
var current_turn := 0

func _ready():
	var players = get_node("../PlayerParty").get_children()
	var enemies = get_node("../EnemyParty").get_children()

	turn_order = players + enemies
	print(turn_order)

func start_turn():
	var actor =turn_order[current_turn]
	if actor.logic.is_player:
		emit_signal("player_turn",actor)
	else:
		actor.logic.take_enemy_turn()
		next_turn()

func next_turn():
	current_turn = (current_turn +1) % turn_order.size()
	start_turn()
