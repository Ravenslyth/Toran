extends Resource
class_name CharacterLogic

@export var character_name: String
@export var level: int = 1
@export var current_hp: int = 100
@export var max_hp: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var range: Vector2

@export var inventory: Array[object] = []

@export var equipment: Equipment

# Optionnel : effets de statut, expérience, etc.
@export var status_effects: Array[String] = []
@export var experience: int = 0
@export var base_speed: int = 150
@export var default_speed: int = 150
@export var agility: int = 0
@export var base_deplacment : int = 0
@export var RadiusDetection : int = 0
@export var playabledCharacter : bool = false
@export var team : String
@export var direction : Vector2

#active le shader de sélection d'un character
func set_outline_progress(value, animated_sprite : AnimatedSprite2D):
	var shader_mat := animated_sprite.material
	if animated_sprite.material is ShaderMaterial:
		shader_mat.set_shader_parameter("progress",value)
