extends Node2D
class_name Weapon
export var path_to_animation = NodePath()
onready var animationPlayer = get_node(path_to_animation)
var ammoDifference
export var maxAmmoCapacity = 180
export var maxMagCapacity = 30
export var reloadTime: int = 1
export var mag = 30
export var ammo = 30
export var endOfGunSize = 7
export var gunSize = 15
export var semi_auto = false
export (PackedScene) var Bullet
export (Texture) var SpriteTexture
export (int) var SpriteHframes
export (int) var SpriteVframes
export (int) var SpriteFrame
onready var attackCooldown = $AttackCooldown
onready var player = get_parent().get_parent()
onready var sprite = $Sprite
onready var endOfGun = $EndOFGun
onready var magReloadTimer = $MagReloadTimer

func _ready():
	print(animationPlayer)
	print(animationPlayer.get_animation_list())
	render()
	pass

func render():
	sprite.texture = SpriteTexture
	sprite.hframes = SpriteHframes
	sprite.vframes = SpriteVframes
	sprite.frame = SpriteFrame

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
		animationPlayer.play("RESET")
		animationPlayer.play("weapon_recoil")
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
	animationPlayer.play("RESET")
	if "FastMag" in player.perks:
		print(reloadTime)
		var reloadTimeResult = reloadTime * 0.34
		print(reloadTimeResult)
		magReloadTimer.wait_time = reloadTimeResult
		animationPlayer.playback_speed = 3
	animationPlayer.play("weapon_reload")
	if ammo > 0 and mag < maxMagCapacity:
		ammoDifference = maxMagCapacity - mag
		if ammo < ammoDifference:
			ammoDifference = ammo  # Lower the ammoDifference if ammo is less than the calculated difference
		magReloadTimer.stop()
		magReloadTimer.start()
		magReloadTimer.connect("timeout", self, "_on_mag_reload_finish")

func _on_mag_reload_finish():
	magReloadTimer.wait_time = reloadTime
	animationPlayer.playback_speed = 1
	ammo -= ammoDifference
	mag += ammoDifference
	
func cancel_reload():
	magReloadTimer.wait_time = reloadTime	
	animationPlayer.playback_speed = 1
	magReloadTimer.stop()
	ammoDifference = 0;

func add_max_ammo():
	ammo = maxAmmoCapacity

func set_rotation(rotation):
	sprite.rotation = rotation
	
func set_gun_position(glob_pos, direction):
	sprite.global_position = glob_pos + direction * gunSize
	
func set_end_of_gun_position(glob_pos, direction):
	endOfGun.global_position = glob_pos + direction * (gunSize + endOfGunSize)

func set_flip_v(flip):
	sprite.flip_v = flip

func set_attack_cooldown_wait_time(wait_time):
	attackCooldown.wait_time = wait_time

func get_attack_cooldown_wait_time():
	return attackCooldown.wait_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
