extends CharacterBody2D

class_name ennemy

#---------------------- Select the node player in the scene of game------------------------

@export var target : Node2D

#----------------------Statut of move----------------------------------------------

var see_player : bool = false # use when the ennemie see the player
var last_move : bool = false # use when the ennemie finish the navigation 
var move_to_origine_position : bool = false

#-----------------Navigation agent 2d---------------(

@onready var navigation_agent_2d = $NavigationAgent2D

#----------------Timer preload------------------------

@onready var out_of_view = $OutOfView
@onready var back_to_origine_position = $BackToOriginePosition

#----------------Label preload-------------------

@onready var see_you = $See_you
@onready var not_see_you = $Not_See_you

#--------------------Origine position------------------

var origine_position = Vector2.ZERO

#------------------Speed------------------------------

@export var speed = 100

#----------------------------------------------------

func _ready():
	origine_position = global_position

func _process(delta):
	#------------------------Move at the player-----------------------
	if (not see_player or see_player) and not last_move:
		var direction = to_local(navigation_agent_2d.get_next_path_position())
		direction = direction.normalized()
		velocity = direction * speed
	elif move_to_origine_position and last_move:
		var direction = to_local(navigation_agent_2d.get_next_path_position())
		direction = direction.normalized()
		velocity = direction * speed
	elif not move_to_origine_position:
		velocity = Vector2.ZERO
	move_and_slide()
	#------------------------End Move at the player-----------------------

#-----------------------Reload the move at the player----------------------
func _on_reload_position_timeout():
	if see_player:
		navigation_agent_2d.target_position = target.position

#------------------Detect Player-----------------------
func _on_zone_of_detection_body_entered(body):
	if body.name == "Player":
		see_player = true
		last_move = false
		out_of_view.stop()
		see_you.show()
		not_see_you.hide()
		print("hum")
	print("lala")

#------------------End Detect Player-----------------------

#------------------Player Out Detection--------------------
func _on_zone_of_detection_body_exited(body):
	out_of_view.start()
	see_player = false
	move_to_origine_position = true
	see_you.hide()
	not_see_you.show()
	print("exited")


func _on_out_of_view_timeout():
	navigation_agent_2d.target_position = origine_position
	move_to_origine_position = true
	not_see_you.hide()

func _on_navigation_agent_2d_navigation_finished():
	velocity = Vector2.ZERO
	last_move = true
	move_to_origine_position = false
	print("stop")
#------------------End Player Out Detection--------------------
