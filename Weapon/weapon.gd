extends Node2D
class_name Weapon

var ammoDifference
export var maxMagCapacity = 30
export var mag = 30
export var ammo = 30
export (PackedScene) var Bullet
onready var attackCooldown = $AttackCooldown
onready var player = get_parent().get_parent()
onready var sprite = $Sprite
onready var endOfGun = $EndOFGun
onready var magReloadTimer = $MagReloadTimer
var semi_auto = false

func _ready():
	pass # Replace with function body.

func shoot():
	if attackCooldown.is_stopped():
		if not "UnlimitedFire" in player.power_ups:
			if mag > 0:
				mag -= 1
			elif ammo == 0:
				return
			else:
				reload()
				return
		cancel_reload()
		attackCooldown.start()
		var bullet_instance = Bullet.instance()
		add_child(bullet_instance)
		bullet_instance.global_position = endOfGun.global_position
		var target = get_global_mouse_position()
		var direction_to_mouse = global_position.direction_to(target).normalized()
		bullet_instance.set_direction(direction_to_mouse)
		var angle = deg2rad(45)
		var right_direction = direction_to_mouse.rotated(angle)
		var left_direction = direction_to_mouse.rotated(-angle)
		if ("MultipleWeapons" in player.power_ups):
			for direction in ["UpLeft", "UpRight"]:
				var new_direction
				if (direction == "UpLeft"):
					new_direction = (direction_to_mouse + left_direction).normalized()
				if (direction == "UpRight"):
					new_direction = (direction_to_mouse + right_direction).normalized()
				var seccond_bullet_instance = Bullet.instance()
				add_child(seccond_bullet_instance)
				seccond_bullet_instance.global_position = endOfGun.global_position
				seccond_bullet_instance.set_direction(new_direction)

func reload():
	if ammo > 0 and mag < maxMagCapacity:
		ammoDifference = maxMagCapacity - mag
		if ammo < ammoDifference:
			ammoDifference = ammo  # Lower the ammoDifference if ammo is less than the calculated difference
		magReloadTimer.start()
		magReloadTimer.connect("timeout", self, "_on_mag_reload_finish")

func _on_mag_reload_finish():
	ammo -= ammoDifference
	mag += ammoDifference
	
func cancel_reload():
	magReloadTimer.stop()
	ammoDifference = 0;


func set_rotation(rotation):
	sprite.rotation = rotation
	
func set_position(position):
	sprite.global_position = position
	
func set_end_of_gun_position(position):
	endOfGun.global_position = position

func set_flip_v(flip):
	sprite.flip_v = flip

func set_attack_cooldown_wait_time(wait_time):
	attackCooldown.wait_time = wait_time

func get_attack_cooldown_wait_time():
	return attackCooldown.wait_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
