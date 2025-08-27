extends Node2D
class_name noise

@export var noise_scene : PackedScene 
#@export var noise_position : Vector2


func _ready():
	pass

func _process(delta):
	pass

func noise_chargement(sound):
	var noise_instantiate = noise_scene.instantiate()
	
	var add = noise_instantiate.noise
	match sound:
		1: # Glock fire noise
			noise_instantiate.global_position = $"../Player".global_position
			noise_instantiate.sound_chargement(add.Glock)
		2: # Walk noise
			noise_instantiate.global_position = $"../Player".global_position
			noise_instantiate.sound_chargement(add.Walk)
			
	get_parent().add_child(noise_instantiate)
