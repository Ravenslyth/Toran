extends Area2D

@onready var weapon_data := preload("res://model/Weapon.gd").new()

func _ready():
	weapon_data.name = "Knife"
	weapon_data.damage = 20
	weapon_data.energy_cost = 1


