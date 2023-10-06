extends CanvasLayer

export var path_to_player = NodePath()
onready var _player = get_node(path_to_player)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var inventory_slots = $GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("open_inventory", self, "_on_open_inventory")
	for inv_slot in inventory_slots.get_children():
		inv_slot.item_name = "BuyWeaponPistol"

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
