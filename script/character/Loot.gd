extends Node2D

#Nécessite que l'objet ai un AREA 2D et un UI "Ramasser"

@onready var label = $Label
var player_in_range = false

func _ready():
	label.visible = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		pick_up()

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		label.visible = true
		player_in_range = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		label.visible = false
		player_in_range = false

func pick_up():
	# Ramasser l'objet
	print("Objet ramassé !")
	queue_free()  # Supprime l'objet de la scène
