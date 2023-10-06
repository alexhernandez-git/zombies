extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ItemClass = preload("res://GUI/item.tscn")
var item
export var item_name: String
var is_mouse_in = false
var is_valid = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var pistol : Rect2 = Rect2(Vector2(0, 0), Vector2(16, 16))
	var shotgun : Rect2 = Rect2(Vector2(16, 0), Vector2(16, 16))
	var ak47 : Rect2 = Rect2(Vector2(32, 0), Vector2(16, 16))

	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	

	var custom_region  # Define your custom region	
	if "Pistol" in item_name:
		custom_region = pistol
	elif "Shotgun" in item_name:
		custom_region = shotgun
	elif "AK47" in item_name:
		custom_region = ak47
	else:
		print("entra")
		$TextureRect.texture = null
		is_valid = false
		return
	if $TextureRect.texture:
		is_valid = true
		$TextureRect.texture.region = custom_region

func _on_mouse_entered():
	# Change the item's appearance when the mouse enters.
	self.modulate = Color(1, 1, 1, 0.7)
	is_mouse_in = true

func _on_mouse_exited():
	# Restore the item's appearance when the mouse exits.
	self.modulate = Color(1, 1, 1, 1)
	is_mouse_in = true

func _input(event):
	if event.is_action_released("shoot") and is_mouse_in and is_valid:
		var parent = get_parent().get_parent()
		get_tree().paused = false
		parent._player.call_supplies(item_name)
		parent.visible = false
		Globals.emit_signal("close_inventory")
	
