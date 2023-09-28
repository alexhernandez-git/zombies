extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var current_weapon: Weapon = $Pistol


var weapons: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	weapons = get_children()

	for weapon in weapons:
		weapon.hide()

	current_weapon.show()

func _process(delta: float) -> void:
	if not current_weapon.semi_auto and Input.is_action_pressed("shoot"):
		current_weapon.shoot()


func get_current_weapon() -> Weapon:
	return current_weapon

func reload():
	current_weapon.start_reload()
		
func switch_weapon(weapon: Weapon):
	if weapon == current_weapon:
		return

	current_weapon.hide()
	weapon.show()
	current_weapon = weapon

func set_weapon_rotation(rotation):
	current_weapon.rotation = rotation
	
func set_weapon_position(position):
	current_weapon.global_position = position
	
func set_weapon_end_of_gun_position(position):
	current_weapon.global_position = position

func set_weapon_flip_h(flip):
	current_weapon.flip_h = flip
	
func add_ammo(amount):
	current_weapon.ammo += amount
	

func _unhandled_input(event: InputEvent) -> void:
	if current_weapon.semi_auto and event.is_action_released("shoot"):
		current_weapon.shoot()
	elif event.is_action_released("reload"):
		current_weapon.reload()
	elif event.is_action_released("weapon_1"):
		switch_weapon(weapons[0])
	elif event.is_action_released("weapon_2"):
		switch_weapon(weapons[1])
