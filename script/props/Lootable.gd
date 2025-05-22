extends StaticBody2D

@export var obj : object

func _ready():
	if obj and obj.icon:
		$TextureRect.texture = obj.icon
		$TextureRect.expand = true

func collect(inventory:Inventory):
	inventory.insert(obj)
	queue_free()
