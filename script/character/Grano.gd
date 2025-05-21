extends Node2D

@onready var logic := preload("res://model/character/PlayerCharacter.gd").new()
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	logic.player_id = 2
	logic.base_speed = 150
	logic.default_speed = 200
	logic.detection = Vector2(3,3)
 
 
