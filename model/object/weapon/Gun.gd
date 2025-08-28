# Dans gun.gd
class_name Gun
extends Weapon

@export var ammo_type: String = "9mm"
@export var max_ammo: int = 6
@export var current_ammo: int = 6

var offset = Vector2i(500, 500)  

func use(user):
	print("Le joueur attaque avec %s et inflige %d dégâts." % [name, damage])

func rangeWeapon() -> Vector2i:
	return range

func attack_normal_zone(center: Vector2i) -> Array[Vector2i]:
	var zone: Array[Vector2i] = []
	zone.append(center)
	# Gauche / Droite
	for i in range(1, int(range.x) + 1):
		zone.append(center + Vector2i.LEFT * i)
		zone.append(center + Vector2i.RIGHT * i)
		
	# Haut / Bas
	for i in range(1, int(range.y) + 1):
		zone.append(center + Vector2i.UP * i)
		zone.append(center + Vector2i.DOWN * i)
		
	return zone

func attack_normal(target : Node2D):
	if current_ammo > 0:
		target.character_logic.current_hp -= damage
		current_ammo -= 1
		print(current_ammo)
		target.death()
 
