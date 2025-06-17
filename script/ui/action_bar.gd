extends Control

signal action_completed

@onready var progress_bar = $TextureProgressBar
@onready var timer = $Timer

var player = null

var duration := 1.0  # Durée totale de l'action
var time_elapsed := 0.0

func _ready():
	hide()
	# S'assure que le signal est connecté si ce n'est pas fait dans l'éditeur
	if not timer.timeout.is_connected(_on_Timer_timeout):
		timer.timeout.connect(_on_Timer_timeout)

func set_time(time):
	if player:
		player.can_move = false
	show()
	duration = time
	time_elapsed = 0.0
	progress_bar.value = 0
	timer.wait_time = 0.01  # Mise à jour très fluide (100 fois par seconde)
	timer.start()

func _on_Timer_timeout():
	time_elapsed += timer.wait_time
	var progress = clamp(time_elapsed / duration, 0, 1)
	progress_bar.value = progress * 100
	
	if time_elapsed >= duration:
		progress_bar.value = 100  # Pour s'assurer que la barre est pleine
		timer.stop()
		hide()
		emit_signal("action_completed")
