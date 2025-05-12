extends Resource

class_name Inventory

signal updated

@export var slots: Array[InventorySlot]

func insert(item: object):
	if item.isStackable:
		var itemSlots = slots.filter(func(slot): return slot.item == item)
		if !itemSlots.is_empty():
			itemSlots[0].amount += 1
			updated.emit()
			return
	
	# Si non stackable OU pas de slot existant, chercher un emplacement vide
	var emptySlots = slots.filter(func(slot): return slot.item == null)
	if !emptySlots.is_empty():
		emptySlots[0].item = item
		emptySlots[0].amount = 1
		updated.emit()
