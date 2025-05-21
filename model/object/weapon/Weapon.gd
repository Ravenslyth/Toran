class_name Weapon
extends object

@export var damage: int
@export var energy_cost: int
@export var range: float

func on_use(user):
	print("utilisation de l'arme %s par %s" % [name, user.name])
	# À implémenter dans les enfants
