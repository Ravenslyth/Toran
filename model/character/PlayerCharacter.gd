class_name PlayerCharacter
extends Character

var player_id: int = 0
var detection : Vector2 = Vector2(0,0)

var object_current_loot : Area2D = null

var inventory: Array = []
var MAX_INVENTORY_SIZE := 0

var equipment := {
	"main_weapon": null,
	"off_weapon": null,
	"helmet": null,
	"armor": null,
	"boots": null
}

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

#-----------------------ADD ITEM INVENTORY-------------------------#
#0003
func add_item_inventory(object_current):
	if inventory.size() >= MAX_INVENTORY_SIZE:
		print("To much object .....")
		return
		
	print("Its could be useful ...")
	inventory.append(object_current.obj)

	object_current.queue_free()
	
	if object_current == object_current_loot:
		object_current_loot = null
	
	#0004
	equip_items("main_weapon",object_current.obj)
	

#---------------------END ADD ITEM INVENTORY-----------------------#
