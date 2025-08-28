extends Node2D

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

@export var character_logic: CharacterLogic
@export var map : TileMap
@export var listCharacter : Array

var tile_position: Vector2i

func _ready():
	pass


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


func test():
	print(map)
