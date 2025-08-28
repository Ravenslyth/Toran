extends object
class_name Trap

@export var activation_radius: Vector2      # Distance à laquelle le piège s'active
@export var trigger_delay: float            # Temps entre le déclenchement et l'effet
@export var reusable: bool                  # Peut-il être réutilisé ?
@export var visible: bool                   # Est-il visible pour l'ennemi ?
@export var duration: float                 # Temps avant disparition automatique (0 = permanent)
@export var is_lethal: bool                 # Est-ce un piège létal ?

@export var trap_scene:PackedScene

func on_use(position: Vector2, parent: Node, obj : object):
	if trap_scene:
		var trap_instance = trap_scene.instantiate()
		trap_instance.trap_data = obj
		trap_instance.global_position = position  # important : global_position et non local
		parent.add_child(trap_instance)

