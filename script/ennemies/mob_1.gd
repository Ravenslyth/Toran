extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	logic.base_speed = 200
	logic.player_id = 1
	logic.detection = Vector2(2,2)
