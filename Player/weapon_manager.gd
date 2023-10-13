extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var current_weapon = $Pistol

onready var current_weapon_index = 0

export var path_to_player = NodePath()
onready var player = get_node(path_to_player)
var weapons: Array = []
var active_weapons: Array = []
var mirror_weapon

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("max_ammo", self, "_on_max_ammo")
	weapons = get_children()
	#active_weapons = [current_weapon]
	active_weapons = weapons
	for weapon in weapons:
		weapon.hide()
		
	for weapon in active_weapons:
		weapon.hide()
		
	if current_weapon:
		current_weapon.show()

func _process(delta: float) -> void:
	if Input.is_action_just_released("next_weapon"):
		next_weapon()
	elif Input.is_action_just_released("previous_weapon"):
		previous_weapon()

	if not current_weapon.semi_auto and Input.is_action_pressed("shoot"):
		current_weapon.shoot()
		if mirror_weapon:
			mirror_weapon.shoot()


func get_current_weapon():
	return current_weapon

func reload():
	current_weapon.start_reload()
	if mirror_weapon:
		mirror_weapon.start_reload()

func switch_weapon(weapon):
	if weapon == current_weapon:
		return
	remove_mirror_weapon()
	current_weapon.hide()
	weapon.show()
	weapon.render()
	current_weapon.fire.stop()
	reset_quick_fire()
	current_weapon = weapon
	if "MultipleWeapons" in player.power_ups:
		add_mirror_current(weapon)
	if "QuickFire" in player.power_ups:
		quick_fire()

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
	if event.is_action_pressed("shoot") and current_weapon.semi_auto:
		current_weapon.shoot()
		if mirror_weapon:
			mirror_weapon.shoot()
	if event.is_action_released("reload"):
		current_weapon.reload()
		if mirror_weapon:
			mirror_weapon.reload()
	elif event.is_action_released("weapon_1"):
		switch_weapon(active_weapons[0])
	elif event.is_action_released("weapon_2"):
		switch_weapon(active_weapons[1])

func add_weapon(name):
	remove_mirror_weapon()
	var maxWeaponsCapacity = 2
	if "MoreWeapons" in player.perks:
		maxWeaponsCapacity = 3
	if active_weapons.size() > maxWeaponsCapacity - 1:
		active_weapons.erase(current_weapon)
	for weapon in weapons:
		if weapon.name == name:
			active_weapons.append(weapon)
			
			for w in weapons:
				w.hide()
		
			for w in active_weapons:
				w.hide()
			weapon.show()
			current_weapon = weapon
			if "MultipleWeapons" in player.power_ups:
				add_mirror_current(weapon)
	if "QuickFire" in player.power_ups:
		quick_fire()

func add_max_ammo():
	current_weapon.ammo = current_weapon.maxAmmoCapacity
	if mirror_weapon:
		mirror_weapon.ammo = mirror_weapon.maxAmmoCapacity

func set_rotation(rotation):
	current_weapon.set_rotation(rotation)
	if mirror_weapon:
		mirror_weapon.set_rotation(rotation)

func set_fire_rotation(rotation):
	current_weapon.set_fire_rotation(rotation)
	if mirror_weapon:
		mirror_weapon.set_fire_rotation(rotation)
		

func set_gun_position(glob_pos, direction):
	current_weapon.sprite.global_position = glob_pos + direction * current_weapon.gunSize
	if mirror_weapon:
		var vector = Vector2(-8, 0)
		if mirror_weapon.sprite.flip_v:
			vector = Vector2(8, 0)
		mirror_weapon.sprite.global_position = glob_pos + vector + direction * mirror_weapon.gunSize
	
func set_end_of_gun_position(glob_pos, direction):
	current_weapon.endOfGun.global_position = glob_pos + direction * (current_weapon.gunSize + current_weapon.endOfGunSize)
	if mirror_weapon:
		var vector = Vector2(-8, 0)
		if mirror_weapon.sprite.flip_v:
			vector = Vector2(8, 0)
		mirror_weapon.endOfGun.global_position = glob_pos + Vector2(-8, 0) + direction * (mirror_weapon.gunSize + mirror_weapon.endOfGunSize)

func set_flip_v(flip):
	current_weapon.sprite.flip_v = flip
	if mirror_weapon:
		mirror_weapon.sprite.flip_v = flip
		

func delete_remaining_weapons():
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
		if weapon.name == name and weapon.ammo == weapon.maxAmmoCapacity:
			return true
	return false

func duplicate_current():
	if mirror_weapon:
		return
	var duplicated_weapon = current_weapon.duplicate()
	current_weapon.get_parent().add_child(duplicated_weapon)
	mirror_weapon = duplicated_weapon

func add_mirror_current(weapon):
	if mirror_weapon:
		return
	var duplicated_weapon = weapon.duplicate()
	weapon.get_parent().add_child(duplicated_weapon)
	mirror_weapon = duplicated_weapon
	mirror_weapon.show()
	mirror_weapon.render()

func quick_fire():
	current_weapon.set_attack_cooldown_wait_time(
		current_weapon.get_attack_cooldown_wait_time() / 2
	)
	current_weapon.fire.quick_fire()
	if mirror_weapon:
		mirror_weapon.set_attack_cooldown_wait_time(
			mirror_weapon.get_attack_cooldown_wait_time() / 2
		)
		mirror_weapon.fire.quick_fire()

func reset_quick_fire():
	current_weapon.set_attack_cooldown_wait_time(
		current_weapon.get_attack_cooldown_wait_time() * 2
	)
	current_weapon.fire.reset_quick_fire()	
	if mirror_weapon:
		mirror_weapon.set_attack_cooldown_wait_time(
			mirror_weapon.get_attack_cooldown_wait_time() * 2
		)
		mirror_weapon.fire.reset_quick_fire()

func remove_mirror_weapon():
	if mirror_weapon:
		mirror_weapon.queue_free()
	mirror_weapon = null
