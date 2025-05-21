extends object
class_name Trap

@export var activation_radius: float  = 10      # Distance à laquelle le piège s'active
@export var trigger_delay: float            # Temps entre le déclenchement et l'effet
@export var reusable: bool                  # Peut-il être réutilisé ?
@export var visible: bool                   # Est-il visible pour l'ennemi ?
@export var duration: float                 # Temps avant disparition automatique (0 = permanent)
@export var is_lethal: bool                 # Est-ce un piège létal ?

func on_use(user):
	print("Pose du piège %s par %s" % [name, user.name])
	# À implémenter dans les enfants
