extends Node2D

var decibelle: int          # N'affecte que le rayon du son
var intensity: int          # l'intensité du son de 1 à 10
var the_noise: AudioStreamPlayer2D

#------------------- Les sons précharger --------------------------------
@onready var glock_fire = $Glock_fire
#------------------------------------------------------------------------

enum noise {
	Glock,
	Walk,
}

func _ready():
	pass

func sound_chargement(sound):
	match sound :
		noise.Glock:
			decibelle = 400 # le rayon du son
			intensity = 8 # l'intensité du son
			$NoiseArea2d/CollisionShape2D.shape.radius = decibelle
			the_noise = $Glock_fire
		noise.Walk:
			decibelle = 100 # le rayon du son
			intensity = 3 # l'intensité du son
			$NoiseArea2d/CollisionShape2D.shape.radius = decibelle
			the_noise = $Walk

# ici les signaux des souns finis sont connecter
func _All_sound_finished():
	queue_free()


func _on_start_noise_timeout():
	the_noise.play()
