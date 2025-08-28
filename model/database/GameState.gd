extends Node

var player_team_data : TeamData = null
var enemy_team_data : TeamData = null

func save_player_data(team: TeamData):
	player_team_data = team

func get_player_data() -> TeamData:
	return player_team_data

func save_enemy_data(team2: TeamData):
	enemy_team_data = team2

func get_enemy_data() -> TeamData:
	return enemy_team_data
