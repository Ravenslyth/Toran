extends Area2D

@onready var weapon_data := preload("res://model/Weapon.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	weapon_data.name = "Gun"
	weapon_data.damage = 35
	weapon_data.energy_cost = 1

 
