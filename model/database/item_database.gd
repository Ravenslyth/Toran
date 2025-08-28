extends Node

var items: Dictionary = {
	"weapon" : {
		"pistol" : "res://ressource/object//weapon/gun/pistol.tres",
		"knife" : "res://ressource/object//weapon/handToHand/knife.tres",
	},
	"trap" : {
		"mine": "res://ressource/object/trap/mine.tres"
	}
}

func get_item(type:String, id: String) -> object: 
	if type in items and id in items[type]:
		return load(items[type][id])
	else:
		print("Item inconnu : %s:%s" % [type, id])
		return null
