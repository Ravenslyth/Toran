extends Node2D

@onready var logic := preload("res://model/PlayerCharacter.gd").new()
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	logic.base_speed = 200
	logic.player_id = 1
	logic.detection = Vector2(2,2)
	logic.MAX_INVENTORY_SIZE = 5

	
 
