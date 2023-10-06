extends CanvasLayer

export var path_to_player = NodePath()
onready var _player = get_node(path_to_player)

var _slot = preload("res://GUI/slot.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var inventory_slots

var items_array = []
var unlocked_array = []

# Called when the node enters the scene tree for the first time.dddddddd
func _ready():
	Globals.connect("open_inventory", self, "_on_open_inventory")
	Globals.connect("unlocked_gun", self, "_on_unlocked_gun")
	Globals.connect("unlocked_perk", self, "_on_unlocked_perk")
	inventory_slots = $GridContainer
	items_array = Globals.weapons
	unlocked_array = _player.unlocked_guns
	inventory_slots.rect_global_position = inventory_slots.rect_global_position + Vector2(00, 0)
	for index in range(items_array.size()):
		var new_slot = _slot.instance()
		inventory_slots.add_child(new_slot)
	render_children()
	inventory_slots = $GridContainer2
	items_array = Globals.perks
	unlocked_array = _player.unlocked_perks
	for index in range(items_array.size()):
		var new_slot = _slot.instance()
		inventory_slots.add_child(new_slot)
	render_children()

func _on_unlocked_gun():
	inventory_slots = $GridContainer
	items_array = Globals.weapons
	unlocked_array = _player.unlocked_guns
	render_children()

func _on_unlocked_perk():
	inventory_slots = $GridContainer2
	items_array = Globals.perks
	unlocked_array = _player.unlocked_perks
	render_children()

func render_children():
	var new_slots = []
	for index in range(unlocked_array.size()):
		var inv_slot = inventory_slots.get_child(index)
		if inv_slot:
			if index < unlocked_array.size():
				if "item_name" in inv_slot:
					if unlocked_array[index] != null:  # Check for null or invalid values
						inv_slot.item_name = unlocked_array[index]
					else:
						# Handle the case where _player.unlocked_guns[index] is invalid
						# For example, print an error message or set a default value.
						print("Error: Invalid value in _player.unlocked_guns")


func _on_open_inventory():
	visible = true

func _input(event):
	if event.is_action_pressed("ui_inventory"):
		Globals.emit_signal("open_inventory")
		get_tree().paused = true
		
	if event.is_action_released("ui_inventory"):
		get_tree().paused = false
		visible = false
		Globals.emit_signal("close_inventory")

func _on_Button_pressed():
	get_tree().paused = false
	visible = false
	Globals.emit_signal("close_inventory")
	
	pass # Replace with function body.
