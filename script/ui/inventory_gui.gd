extends Control

signal inventory_opened()
signal inventory_closed()

@onready var inventory: Inventory = preload("res://ressource/inventory/PlayerInventory.tres")
@onready var slots: Array = $NinePatchRect/CenterContainer/GridContainer.get_children()
@onready var title =  $description/title
@onready var desc =  $description/desc 

@onready var slotBackground = $background

var isOpen: bool = false
var selected_index := 0

var columns := 5

func _ready():
	inventory.updated.connect(update)
	update()
	
func _unhandled_input(event):
	if not isOpen:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Z:
				move_selection("up")
			KEY_S:
				move_selection("down")
			KEY_Q:
				move_selection("left")
			KEY_D:
				move_selection("right")

	
func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func open():
	visible = true
	isOpen = true
	emit_signal("inventory_opened")  
	update_selection()


func close():
	visible = false
	isOpen = false
	emit_signal("inventory_closed")  

func move_selection(dir: String):
	var total_slots = slots.size()
	var row_size = columns

	match dir:
		"up":
			selected_index = max(0, selected_index - row_size)
		"down":
			selected_index = min(total_slots - 1, selected_index + row_size)
		"left":
			if selected_index % row_size != 0:
				selected_index -= 1
		"right":
			if (selected_index + 1) % row_size != 0 and selected_index + 1 < total_slots:
				selected_index += 1

	update_selection()

func update_selection():
	for i in range(slots.size()):
		if i == selected_index:
			slots[i].modulate = Color(1, 1, 0)   
		else:
			slots[i].modulate = Color(1, 1, 1)  
	
	var selected_slot = get_selected_inventory_slot()
	if selected_slot and selected_slot.item:
		title.text = selected_slot.item.name
		desc.text = selected_slot.item.description
	else:
		title.text = ""
		desc.text = ""

func get_selected_inventory_slot() -> InventorySlot:
	if selected_index >= 0 and selected_index < inventory.slots.size():
		return inventory.slots[selected_index]
	return null


func _on_button_pressed():
	var slot = get_selected_inventory_slot()
	if slot and slot.item:
		slot.item.use()
