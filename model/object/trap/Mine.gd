extends Trap
class_name Mine

@export var explosion_radius: float 
@export var damage: int
@export var trap_scene: PackedScene 

func use(user):
	print("%s pose une mine" % user.name)
	if trap_scene:
		var trap_instance = trap_scene.instantiate()
		
		# Ajoute la mine à la scène principale via le user
		user.get_tree().get_current_scene().add_child(trap_instance)

		trap_instance.global_position = user.global_position
		trap_instance.trap_data = self

		# Ajuster collision
		if trap_instance.has_node("CollisionShape2D"):
			var shape = trap_instance.get_node("CollisionShape2D").shape
			if shape is CircleShape2D:
				shape.radius = explosion_radius
	else:
		print("trap_scene n’est pas défini.")
