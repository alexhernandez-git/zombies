extends KinematicBody2D

var speed = 100
var acceleration = 500
var max_speed = 200
var rotation_speed = 2
var position_target: Vector2
var supply_closed_frame = 20
var supply_open_frame = 21
var hasOpened = false
onready var sprite = $Sprite
onready var timer = $Timer
var perk = preload("res://Perks/perk.tscn")
var power_up = preload("res://PowerUps/power_up.tscn")
var weapon = preload("res://BuyWeapon/buy_weapon.tscn")


func _ready():
	position_target = global_position + Vector2(0, 100) 

func _process(delta):
	var target_direction = (position_target - global_position).normalized()

	var velocity = move_and_slide(target_direction * speed, Vector2.ZERO)

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
		move_and_slide(velocity)

	if global_position.distance_to(position_target) < 10.0 and not hasOpened:  # Adjust the threshold as needed
		# Helicopter has arrived at the target position
		hasOpened = true
		sprite.frame = supply_open_frame
		timer.start()
		timer.connect("timeout", self, "_on_timeout")
		
		var object_types = ['perks', 'power_ups', 'weapons']
		
		var random_index = randi() % object_types.size()

		# Get the random item from the array
		var random_type = object_types[random_index]
		
		if random_type == "perks":
			print("Entra")
			
			random_index = randi() % Globals.perks.size()
			var object = perk.instance()
			object.z_index = 100
			object.price = 0
			object.name = Globals.perks[random_index]
			add_child(object)
		if random_type == "power_ups":
			print("Entra 1")
			
			random_index = randi() % Globals.power_ups.size()
			var object = power_up.instance()
			object.z_index = 100
			object.name = Globals.power_ups[random_index]
			add_child(object)
		if random_type == "weapons":
			print("Entra 2")
			
			random_index = randi() % Globals.weapons.size()
			var object = weapon.instance()
			object.z_index = 100
			object.price = 0
			object.name = Globals.weapons[random_index]
			add_child(object)
		print(random_type)

func _on_timeout():
	queue_free()
