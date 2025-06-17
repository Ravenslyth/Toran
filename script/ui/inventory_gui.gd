extends Control


@onready var inventory : Inventory = preload("res://ressource/inventory/playerInventory.tres")
@onready var slots : Array = $Control/NinePatchRect/GridContainer.get_children()
@onready var button : Array = $Control/NinePatchRect2/VBoxContainer.get_children()
@onready var grid_size := Vector2i(4, 2) # exemple : 5 colonnes x 4 lignes
@onready var usableMenu = $Control/NinePatchRect2

@export var player: CharacterBody2D

var isOpen : bool = false

var selected_index := 0
var button_selected_index := 0
var current_object = null

func _ready():
	inventory.updated.connect(update)
	update()

func _unhandled_input(event):
	if not isOpen:
		return

	if event is InputEventKey and event.pressed:
		if usableMenu.visible:
			# Navigation dans les boutons (menu vertical)
			button_selected_index = navigate_grid(event, button, Vector2i(1, button.size()), button_selected_index)
			update_button_selection()

			if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				button[button_selected_index].emit_signal("pressed")  # active le bouton sélectionné
			elif event.keycode == KEY_ESCAPE:
				usableMenu.visible = false  # ferme le menu utilisable
			return

		# Navigation dans la grille des slots
		selected_index = navigate_grid(event, slots, grid_size, selected_index)

		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			if inventory.items[selected_index]:
				usableMenu.visible = true
				button_selected_index = 0
				update_button_selection()
				current_object = inventory.items[selected_index]

		update_selection()

func update_selection():
	for i in range(slots.size()):
		slots[i].modulate = Color.WHITE  # Reset
	slots[selected_index].modulate = Color.YELLOW  # Highlight

func update_button_selection():
	for i in range(button.size()):
		button[i].release_focus()
	button[button_selected_index].grab_focus()

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
	usableMenu.visible = false  
	if player:
		player.can_move = true
 

func navigate_grid(event: InputEventKey, elements: Array, grid_size: Vector2i, current_index: int) -> int:
	var new_index = current_index
	var row = grid_size.y
	var col = grid_size.x

	match event.keycode:
		KEY_D:  # droite
			if (new_index + 1) % col != 0 and new_index + 1 < elements.size():
				new_index += 1
		KEY_Q:  # gauche
			if new_index % col != 0:
				new_index -= 1
		KEY_S:  # bas
			if new_index + col < elements.size():
				new_index += col
		KEY_Z:  # haut
			if new_index - col >= 0:
				new_index -= col

	return new_index


func _on_use_pressed():
	if player:
		if current_object.usable:
			player.objUsed = current_object


func _on_equip_pressed():
	pass # Replace with function body.


func _on_drop_pressed():
	pass # Replace with function body.
