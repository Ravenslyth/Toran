extends Area2D

@export var trap_data: Mine = null

func _ready():
	print("MineProps _ready")
	if trap_data != null:
		var shape = $CollisionShape2D.shape
		if shape is CircleShape2D:
			shape.radius = trap_data.explosion_radius
			print("Radius ajusté à ", trap_data.explosion_radius)
