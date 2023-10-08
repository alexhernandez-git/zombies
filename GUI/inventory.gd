extends CanvasLayer

export var path_to_player = NodePath()
onready var _player = get_node(path_to_player)

var _slot = preload("res://GUI/slot.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var inventory_slots

var perks = []
var weapons = []
var unlocked_perks = []
var unlocked_weapons = []

# Called when the node enters the scene tree for the first time.dddddddd
func _ready():
	Globals.connect("open_inventory", self, "_on_open_inventory")
	Globals.connect("unlocked_gun", self, "_on_unlocked_gun")
	Globals.connect("unlocked_perk", self, "_on_unlocked_perk")
	
	for index in range(Globals.weapons.size()):
		var new_slot = _slot.instance()
		$GridContainer.add_child(new_slot)
	_on_unlocked_gun()
	
	for index in range(Globals.perks.size()):
		var new_slot = _slot.instance()
		$GridContainer2.add_child(new_slot)
	_on_unlocked_perk()

func _on_unlocked_gun():
	for index in range(_player.unlocked_weapons.size()):
		var inv_slot = $GridContainer.get_child(index)
		if inv_slot:
			if index < _player.unlocked_weapons.size():
				if "item_name" in inv_slot:
					if _player.unlocked_weapons[index] != null:  # Check for null or invalid values
						inv_slot.item_name = _player.unlocked_weapons[index]
					else:
						# Handle the case where _player.unlocked_weapons[index] is invalid
						# For example, print an error message or set a default value.
						print("Error: Invalid value in _player.unlocked_weapons")


func _on_unlocked_perk():
	for index in range(_player.unlocked_perks.size()):
		var inv_slot = $GridContainer2.get_child(index)
		if inv_slot:
			if index < _player.unlocked_perks.size():
				if "item_name" in inv_slot:
						inv_slot.item_name = _player.unlocked_perks[index]
				else:
					# Handle the case where _player.unlocked_perks[index] is invalid
					# For example, print an error message or set a default value.
					print("Error: Invalid value in _player.unlocked_perks")

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
