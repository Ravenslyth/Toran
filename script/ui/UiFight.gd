extends Control

signal move_mod
signal action_mod

@onready var buttons = $HBoxContainer/HBoxContainer2/NinePatchRect/VBoxContainer.get_children()
@onready var mainWeaponButtons = $HBoxContainer/HBoxContainer3/NinePatchRect/VBoxContainer/HBoxContainer/HBoxContainer.get_children()    # Liste contenant le bouton main weapon
@onready var secondWeaponButtons  = $HBoxContainer/HBoxContainer3/NinePatchRect/VBoxContainer/HBoxContainer2/HBoxContainer.get_children()    # Liste contenant le bouton main weapon

@onready var selectorGeneral = $HBoxContainer/HBoxContainer2/NinePatchRect/GeneralSelector
@onready var selectorWeapon = $HBoxContainer/HBoxContainer3/NinePatchRect/SelectiorWeapon

@onready var lifePlayer = $HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/HBoxContainer2/TextureProgressBar
@onready var iconMainWeapon = $HBoxContainer/HBoxContainer3/NinePatchRect/VBoxContainer/HBoxContainer/IconMainWeapon
@onready var textMainWeapon = $HBoxContainer/HBoxContainer3/NinePatchRect/VBoxContainer/HBoxContainer/TextMainWeapon

var selected_index = 0
var currentSelector = selectorGeneral
var current_list = []  # Liste active (buttons ou weapons)

func _ready():
	currentSelector = selectorGeneral
	current_list = buttons
	update_selector_position(currentSelector)
	grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("move_up"):
		selected_index = (selected_index - 1 + current_list.size()) % current_list.size()
		update_selector_position(currentSelector)
	elif event.is_action_pressed("move_down"):
		selected_index = (selected_index + 1) % current_list.size()
		update_selector_position(currentSelector)
	elif event.is_action_pressed("validation"):
		current_list[selected_index].emit_signal("pressed")

func update_selector_position(selector: TextureRect):
	var target_button = current_list[selected_index]
	var global_pos = target_button.global_position
	print(target_button.size.y)
	selector.global_position = global_pos + Vector2(-30, target_button.size.y / 2)
	target_button.grab_focus()

func _on_btn_action_pressed():
	selectorGeneral.visible = false
	selectorWeapon.visible = true
	currentSelector = selectorWeapon
	
	
	# Concaténer les boutons main et second weapon
	current_list = mainWeaponButtons + secondWeaponButtons
	
	
	selected_index = 0
	update_selector_position(currentSelector)
	emit_signal("action_mod")


func _on_btn_move_pressed():
	emit_signal("move_mod")
	visible = false 
