extends Node2D

@onready var logic := preload("res://model/PlayerCharacter.gd").new()
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	logic.base_speed = 100
	logic.player_id = 2
	logic.detection = Vector2(3,3)
	logic.MAX_INVENTORY_SIZE = 3
