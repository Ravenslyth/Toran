extends Control


@onready var inventory : Inventory = preload("res://ressource/inventory/playerInventory.tres")
@onready var slots : Array = $NinePatchRect/GridContainer.get_children()
@onready var grid_size := Vector2i(4, 2) # exemple : 5 colonnes x 4 lignes

@export var player: CharacterBody2D

var isOpen : bool = false

var selected_index := 0


func _ready():
	inventory.updated.connect(update)
	update()

func _unhandled_input(event):
	if not isOpen:
		return

	if event is InputEventKey and event.pressed:
		var row = grid_size.y
		var col = grid_size.x

		match event.keycode:
			KEY_D:  # droite
				if (selected_index + 1) % col != 0 and selected_index + 1 < slots.size():
					selected_index += 1
			KEY_Q:  # gauche
				if selected_index % col != 0:
					selected_index -= 1
			KEY_S:  # bas
				if selected_index + col < slots.size():
					selected_index += col
			KEY_Z:  # haut
				if selected_index - col >= 0:
					selected_index -= col
			KEY_ENTER, KEY_SPACE:
				print("Utiliser l'objet :", inventory.items[selected_index])

		update_selection()

func update_selection():
	for i in range(slots.size()):
		slots[i].modulate = Color.WHITE  # Reset
	slots[selected_index].modulate = Color.YELLOW  # Highlight

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])
	update_selection()

func open():
	visible = true
	isOpen = true
	if player:
		player.can_move = false
 

func close():
	visible = false
	isOpen = false
	if player:
		player.can_move = true
 
