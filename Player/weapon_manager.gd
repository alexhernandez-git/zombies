extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var current_weapon = $Pistol

onready var current_weapon_index = 0


var weapons: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	weapons = get_children()

	for weapon in weapons:
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
	if current_weapon_index >= weapons.size():
		current_weapon_index = 0
	switch_weapon(weapons[current_weapon_index])

func previous_weapon():
	current_weapon_index -= 1
	if current_weapon_index < 0:
		current_weapon_index = weapons.size() - 1
	switch_weapon(weapons[current_weapon_index])

func _input(event):
	if event.is_action_pressed("shoot"):
		current_weapon.shoot()

func _unhandled_input(event: InputEvent) -> void:
	if current_weapon.semi_auto and event.is_action_released("shoot"):
		current_weapon.shoot()
	elif event.is_action_released("reload"):
		current_weapon.reload()
	elif event.is_action_released("weapon_1"):
		switch_weapon(weapons[0])
	elif event.is_action_released("weapon_2"):
		switch_weapon(weapons[1])
