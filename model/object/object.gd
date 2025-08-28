class_name object
extends Resource

@export var name: String
@export var description: String
@export var isStackable: bool
@export var icon: Texture2D
@export var nbr : int
@export var usable : bool
@export var lootable : bool
@export var timeUse : float

func use(user):
	print("useddddd")
