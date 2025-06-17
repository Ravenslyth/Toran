extends Node2D

# Récupération des références aux noeuds de la scène
@onready var grid_map = $TurnManager/TileMap
@onready var fight_menu =  $CanvasLayer/HBoxContainer/Ui


@onready var turnManage =  $TurnManager
@onready var playerManager =  $PlayerManager
@onready var enemyManager =   $EnemyManager

@onready var btnMove = $CanvasLayer/VBoxContainer/BtnMove
@onready var btnAction =  $CanvasLayer/VBoxContainer/BtnAction
@onready var btnFlag =  $CanvasLayer/VBoxContainer/BtnFlag
@onready var btnValidation =  $CanvasLayer/VBoxContainer/BtnValidation

var idleMenu = true
var radius := 200.0
var angle := 0.0

# Fonction appelée au démarrage de la scène
func _ready():
	fight_menu.connect("move_mod", Callable(self, "_on_move_selected"))
	fight_menu.connect("action_mod", Callable(self, "_on_action_selected"))
	turnManage.ui = fight_menu

	instanciate_Player()
	instanciate_Enemy()
	grid_map.place_entities_on_tile(Vector2i(11,0),turnManage.turn_queue[0])
	grid_map.place_entities_on_tile(Vector2i(12,-7),turnManage.turn_queue[1])
	grid_map.place_entities_on_tile(Vector2i(12,-6),turnManage.turn_queue[2])
	grid_map.place_entities_on_tile(Vector2i(13,4),turnManage.turn_queue[3])
	
	turnManage.start_turn()


# Fonction appelée lorsqu'un input utilisateur est reçu
func _unhandled_input(event):
	if turnManage.current_character.character_logic.playabledCharacter && !turnManage.current_character.is_moving: 
		if Input.is_action_just_pressed("EndTourFight"):
			turnManage.end_turn()

# Instancie les membres de l'équipe du joueur depuis les données sauvegardées
func instanciate_Player():
	var team_data : TeamData = GameState.get_player_data()
	
	for i in team_data.members.size():
		var member = team_data.members[i]
		var instance = member.combat_scene.instantiate()
		playerManager.add_child(instance)
		instance.map = grid_map
		instance.menu_ref = fight_menu
		turnManage.add_to_turn_queue(instance) 
		
		connectSignal(instance)

# Instancie les membres de l'équipe du joueur depuis les données sauvegardées
func instanciate_Enemy():
	var enemy_team_data : TeamData = GameState.get_enemy_data()
	 
	for i in enemy_team_data.members.size():
		var member = enemy_team_data.members[i]
		var instance = member.combat_scene.instantiate()
		enemyManager.add_child(instance)
		instance.map = grid_map
		turnManage.add_to_turn_queue(instance) 
		
		connectSignal(instance)

func connectSignal(instance):
	instance.IDLE_mode.connect(Callable(turnManage, "_on_IDLE_mode"))
	instance.MOVE_mode.connect(Callable(turnManage, "_on_MOVE_mode"))
	instance.DIRECTION_mode.connect(Callable(turnManage, "_on_DIRECTION_mode"))
	instance.ACTION_mode.connect(Callable(turnManage, "_on_ACTION_mode"))
	instance.END_mode.connect(Callable(turnManage, "_on_END_mode"))
	instance.no_move_left.connect(Callable(turnManage, "_on_no_move_left"))
	instance.character_died.connect(Callable(turnManage, "_on_character_died"))

func _on_move_selected():
	if turnManage.current_character.character_logic.playabledCharacter && !turnManage.current_character.is_moving:
		if !turnManage.no_move_left_round:
			turnManage._on_MOVE_mode()

func _on_action_selected():
	if turnManage.current_character.character_logic.playabledCharacter && !turnManage.current_character.is_moving:
			turnManage._on_ACTION_mode()
