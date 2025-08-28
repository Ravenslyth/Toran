extends Resource

class_name Inventory

signal updated

@export var items: Array[object]

func insert(item:object):
	for i in range(items.size()):
		if !items[i]:
			items[i] = item
			break
	
	updated.emit()

func remove(item: object) -> void:
	for i in range(items.size()):
		if items[i] == item:
			items.remove_at(i)
			updated.emit()
			break
