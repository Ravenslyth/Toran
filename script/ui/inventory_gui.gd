extends Control

var isOpen : bool = false

@onready var inventory : Inventory = preload("res://ressource/inventory/playerInventory.tres")
@onready var slots : Array = $NinePatchRect/GridContainer.get_children()

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])

func open():
	visible = true
	isOpen = true

func close():
	visible = false
	isOpen = false
