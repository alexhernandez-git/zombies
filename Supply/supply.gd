extends KinematicBody2D

var speed = 100
var acceleration = 500
var max_speed = 200
var rotation_speed = 2
var position_target: Vector2
var supply_closed_frame = 0
var supply_open_frame = 1
var hasOpened = false
onready var sprite = $Sprite
onready var timer = $Timer
var perk = preload("res://Perks/perk.tscn")
var power_up = preload("res://PowerUps/power_up.tscn")
var weapon = preload("res://BuyWeapon/buy_weapon.tscn")
var supply: String

func _ready():
	position_target = global_position + Vector2(0, 100) 

func _process(delta):
	if hasOpened:
		return
	var target_direction = (position_target - global_position).normalized()

	var velocity = move_and_slide(target_direction * speed, Vector2.ZERO)

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
		move_and_slide(velocity)

	# TODO: Make free the random supplies

	if global_position.distance_to(position_target) < 10.0 and not hasOpened:  # Adjust the threshold as needed
		# Helicopter has arrived at the target position
		hasOpened = true
		sprite.frame = supply_open_frame
		velocity = Vector2.ZERO  # Set velocity to zero to stop movement
		move_and_slide(velocity)
		
		if supply:
			var object

			if supply in Globals.perks:
				object = perk.instance()
				object.z_index = 100
				object.name = supply
				add_child(object)

			if supply in Globals.weapons:
				object = weapon.instance()
				object.z_index = 100
				var is_trowable = Globals.weapons_data[supply].isTrowable
				if is_trowable:
					object.name = str("BuyTrowable", supply)
				else:
					object.name = str("BuyWeapon", supply)
				add_child(object)

		else:
			var object_types = ['perks', 'weapons']
			
			var random_index = randi() % object_types.size()
			# TODO: If there is not unlocable object left return power ups
			# Get the random item from the array
			var random_type = object_types[random_index]
			var object
			
			if random_type == "perks" and Globals.perks.size() > 0:
				var perks = getItems(Globals.roundCount, Globals.perks)
				print("perks", perks)
				random_index = randi() % perks.size()
				object = perk.instance()
				object.z_index = 100
				object.price = 0
				object.name = perks[random_index]
				add_child(object)

			if random_type == "weapons" and Globals.weapons.size() > 0:
				var weapons = getItems(Globals.roundCount, Globals.weapons)
				print("weapons", weapons)
				random_index = randi() % weapons.size()
				object = weapon.instance()
				object.price = 0
				object.z_index = 100
				var is_trowable = Globals.weapons_data[weapons[random_index]].isTrowable
				if is_trowable:
					object.name = str("BuyTrowable", weapons[random_index])					
				else:
					object.name = str("BuyWeapon", weapons[random_index])
				add_child(object)
				
			if not object:
				random_index = randi() % Globals.power_ups.size()
				object = power_up.instance()
				object.z_index = 100
				object.name = Globals.power_ups[random_index]
				add_child(object)
				timer.start()
				timer.connect("timeout", self, "_on_timeout")

func getItems(value: int, array: Array) -> Array:
	var itemCount = min(floor(value / 5) + 3, array.size())  # Calculate the number of items to retrieve based on the value
	return array.slice(0, itemCount)  # Slice the array to get the desired number of items


func _on_timeout():
	queue_free()
