class_name PlayerCharacter
extends Character

 

var player_id: int = 0
var detection : Vector2 = Vector2(2,2)

<<<<<<< Updated upstream
var inventory: Array = []
var Equipement: Array = []
var MAX_INVENTORY_SIZE := 5
=======
>>>>>>> Stashed changes


#-----basic Animation character
func play_movement_animation(direction: Vector2, animated_sprite: AnimatedSprite2D):
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
<<<<<<< Updated upstream
=======

#-----------------------FUNCTION EQUIP ITEM-------------------------#

#0004
func equip_items(slot_name:String, item: object) -> bool:
	if not equipment.has(slot_name):
		return false
	
	match slot_name:
		"main_weapon","off_weapon":
			if not item is Weapon:
				return false
	
	equipment[slot_name] = item
	return true

#---------------------END FUNCTION EQUIP ITEM-----------------------#


>>>>>>> Stashed changes
