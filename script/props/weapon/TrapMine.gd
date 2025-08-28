extends Node2D

var trap_data: Trap  # variable pour stocker la référence à la resource

@onready var activationR = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	activationR.scale = trap_data.activation_radius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
