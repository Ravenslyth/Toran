class_name Gun
extends Weapon

@export var ammo_type: String = "9mm"
@export var max_ammo: int = 6
@export var current_ammo: int = 6

func use(user):
	print("Le joueur attaque avec %s et inflige %d dégâts." % [name, damage])
	# Tu peux accéder à `user` ici, donc au `Player` ou au Node appelant
