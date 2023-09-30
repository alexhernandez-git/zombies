extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var current_weapon = $Pistol

onready var current_weapon_index = 0


var weapons: Array = []
var active_weapons: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("max_ammo", self, "_on_max_ammo")
	weapons = get_children()
	active_weapons = [current_weapon]

	for weapon in weapons:
		weapon.hide()
		
	for weapon in active_weapons:
		weapon.hide()
		
	current_weapon.show()

func _process(delta: float) -> void:
	if Input.is_action_just_released("next_weapon"):
		next_weapon()
	elif Input.is_action_just_released("previous_weapon"):
		previous_weapon()

	if not current_weapon.semi_auto and Input.is_action_pressed("shoot"):
		current_weapon.shoot()


func get_current_weapon():
	return current_weapon

func reload():
	current_weapon.start_reload()
		
func switch_weapon(weapon):
	if weapon == current_weapon:
		return

	current_weapon.hide()
	weapon.show()
	weapon.render()
	current_weapon = weapon

func next_weapon():
	current_weapon_index += 1
	if current_weapon_index >= active_weapons.size():
		current_weapon_index = 0
	switch_weapon(active_weapons[current_weapon_index])

func previous_weapon():
	current_weapon_index -= 1
	if current_weapon_index < 0:
		current_weapon_index = active_weapons.size() - 1
	switch_weapon(active_weapons[current_weapon_index])

func _input(event):
	if event.is_action_pressed("shoot"):
		current_weapon.shoot()

func _unhandled_input(event: InputEvent) -> void:
	if current_weapon.semi_auto and event.is_action_released("shoot"):
		current_weapon.shoot()
	elif event.is_action_released("reload"):
		current_weapon.reload()
	elif event.is_action_released("weapon_1"):
		switch_weapon(active_weapons[0])
	elif event.is_action_released("weapon_2"):
		switch_weapon(active_weapons[1])

func add_weapon(name):
	for weapon in weapons:
		if weapon.name == name:
			active_weapons.append(weapon)
			
			for w in weapons:
				w.hide()
		
			for w in active_weapons:
				w.hide()
			weapon.show()
			current_weapon = weapon
	if active_weapons.size() > 2:
		active_weapons.pop_front()
			
func add_ammo(name):
	for weapon in active_weapons:
		if weapon.name == name:
			weapon.ammo = weapon.maxAmmoCapacity

func _on_max_ammo():
	for weapon in active_weapons:
		weapon.ammo = weapon.maxAmmoCapacity

func _is_gun_full_ammo(name):
	for weapon in active_weapons:
		if weapon.ammo == weapon.maxAmmoCapacity:
			return true
	return false
