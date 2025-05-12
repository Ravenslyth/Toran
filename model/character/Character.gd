class_name Character
extends Node

var base_speed := 300
var speed_bonus := 0
var speed_malus := 0

#-----get speed
func get_speed() -> int:
	return base_speed + speed_bonus - speed_malus

