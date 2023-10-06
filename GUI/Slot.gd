extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ItemClass = preload("res://GUI/item.tscn")
var item
var item_name: String
var is_mouse_in = false
var is_gun

var has_sprite = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")

func _process(delta):
	print(str("item_name", item_name))
	for gun in Globals.weapons:
		if gun in item_name:
			is_gun = true
			$Sprite.frame = Globals.weapons_data[gun].frame
			has_sprite = true
	if not has_sprite:
		$Sprite.frame = 35

func _on_mouse_entered():
	# Change the item's appearance when the mouse enters.
	self.modulate = Color(1, 1, 1, 0.7)
	is_mouse_in = true

func _on_mouse_exited():
	# Restore the item's appearance when the mouse exits.
	self.modulate = Color(1, 1, 1, 1)
	is_mouse_in = false

func _input(event):
	if event.is_action_released("shoot") and is_mouse_in and has_sprite and get_parent().get_parent().visible:
		var clean_item_name = Globals.get_clean_string(item_name)
		var parent = get_parent().get_parent()
		get_tree().paused = false
		if is_gun:
			parent._player.call_supplies(clean_item_name)
		else:
			pass
		parent.visible = false
		Globals.emit_signal("close_inventory")
