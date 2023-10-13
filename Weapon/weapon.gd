extends Node2D
class_name Weapon
export var path_to_animation = NodePath()
onready var animationPlayer = get_node(path_to_animation)
export var path_to_shoot_audio = NodePath()
onready var shootAudio = get_node(path_to_shoot_audio)
export var path_to_reload_audio = NodePath()
onready var reloadAudio = get_node(path_to_reload_audio)
var ammoDifference
export var maxAmmoCapacity = 180
export var maxMagCapacity = 30
export var reloadTime: float = 1
export var mag = 30
export var damage = 20
export var ammo = 30
export var cadence = 0.1
export var isShotgun = false
export var gunshotDispersion = 5
export var endOfGunSize = 7
export var gunSize = 15
export var semi_auto = false
export var isFlamethrower = false
export var burst = false
export var burstTime = 0.5
export var burstShots = 3
var burstCounter = 0
export var isGrenadeLauncher = false
export var grenadeLauncherSpeed = 500
var Bullet = preload("res://Player/bullet.tscn")
var Grenade = preload("res://Player/grenade.tscn")
onready var attackCooldown = $AttackCooldown
onready var burstCooldown = $BurstCooldown
onready var player = get_parent().get_parent()
onready var sprite = $Sprite
onready var endOfGun = $EndOFGun
onready var magReloadTimer = $MagReloadTimer
onready var endOfGunSprites = [$EndOFGun/Light1,$EndOFGun/Light2,$EndOFGun/Light3,$EndOFGun/Light4]
onready var shotLightTimer = $ShotLight
onready var fire = $EndOFGun/Fire

var is_shooting = false

func _ready():
	mag = maxMagCapacity
	render()
	pass

func render():
	var cleaned_string = Globals.get_clean_string(name)
	if cleaned_string in Globals.weapons_data:
		sprite.frame = Globals.weapons_data[cleaned_string].frame
	attackCooldown.wait_time = cadence
	magReloadTimer.wait_time = reloadTime
	burstCooldown.wait_time = burstTime
	

func shoot():
	if not  burst and attackCooldown.is_stopped() or burst and attackCooldown.is_stopped()  and burstCooldown.is_stopped() and burstCounter < burstShots:
		
		if not "UnlimitedFire" in player.power_ups:
			if mag > 0:
				mag -= 1
			elif ammo == 0:
				return
			else:
				if magReloadTimer.is_stopped():
					fire.visible = false
					reload()
				return
		is_shooting = true
		shotLightTimer.start()
		shotLightTimer.connect("timeout", self, "_on_timeout_shot_light")
		if not isFlamethrower or isFlamethrower and not shootAudio.is_playing():
			shootAudio.play()
		animationPlayer.play("RESET")
		animationPlayer.play("weapon_recoil")
		cancel_reload()
		var target = get_global_mouse_position()
		var direction_to_mouse = global_position.direction_to(target).normalized()
		attackCooldown.start()
		
		if isGrenadeLauncher:
			var grenade = Grenade.instance() as RigidBody2D
			grenade.damage = damage
			grenade.explode_on_touch = true
			var player_direction = get_global_mouse_position() - global_position
			var distance = player_direction.length()
			var speed_scaling_factor = 1000.0 / (distance + 100.0)  # Adjust this factor as needed
			var speed = grenadeLauncherSpeed * (distance / speed_scaling_factor + 1.0)
			Globals.emit_signal("trow_object",  endOfGun.global_position, player_direction.normalized(), speed, grenade)
			return
		if isFlamethrower:
			fire.fire(endOfGun.global_position)
			fire.player = player
			fire.damage = damage
			return
		if burst:
			attackCooldown.connect("timeout", self, "_on_attack_cooldown_timeout")
		if isShotgun:
			var initialDegree = 0
			var degrees = []
			for i in range(5):
				degrees.append(-deg2rad(initialDegree))
				degrees.append(deg2rad(initialDegree))
				initialDegree += gunshotDispersion
			for degree in degrees:
				var new_direction = (direction_to_mouse + direction_to_mouse.rotated(degree)).normalized()
				var seccond_bullet_instance = Bullet.instance()
				seccond_bullet_instance.collateral = false
				seccond_bullet_instance.player = player
				add_child(seccond_bullet_instance)
				seccond_bullet_instance.global_position = endOfGun.global_position
				seccond_bullet_instance.set_damage(damage)
				seccond_bullet_instance.set_direction(new_direction)
		else:
			var bullet_instance = Bullet.instance()
			bullet_instance.player = player
			add_child(bullet_instance)
			bullet_instance.global_position = endOfGun.global_position
			bullet_instance.set_damage(damage)
			set_random_shot_light_sprite_random()
			bullet_instance.set_direction(direction_to_mouse)

func _on_attack_cooldown_timeout():
	if burstCounter >= burstShots - 1:
		burstCooldown.start()
		burstCounter = 0
		return
	burstCounter += 1
	shoot()

func set_random_shot_light_sprite_random():
	for sprite in endOfGunSprites:
		sprite.visible = false

	# Choose a random sprite to show
	var random_index = randi() % endOfGunSprites.size()
	var random_sprite = endOfGunSprites[random_index]
	random_sprite.visible = true
	random_sprite.rotation = sprite.rotation
	random_sprite.flip_v = sprite.flip_v

func _on_timeout_shot_light():
	is_shooting = false
	for sprite in endOfGunSprites:
		sprite.visible = false

func reload():
	animationPlayer.play("RESET")
	if ammo > 0 and mag < maxMagCapacity:
		shootAudio.stop()
		animationPlayer.playback_speed = 1.0 / reloadTime
		reloadAudio.pitch_scale = 1.0 / reloadTime
		if "FastMag" in player.perks:
			var reloadTimeResult = reloadTime * 0.34
			magReloadTimer.wait_time = reloadTimeResult
			animationPlayer.playback_speed = (1.0 / reloadTime) * 3.0
			reloadAudio.pitch_scale = (1.0 / reloadTime) / 3
		animationPlayer.play("weapon_reload")
		reloadAudio.play(0.0)
		ammoDifference = maxMagCapacity - mag
		if ammo < ammoDifference:
			ammoDifference = ammo  # Lower the ammoDifference if ammo is less than the calculated difference
		magReloadTimer.stop()
		magReloadTimer.start()
		magReloadTimer.connect("timeout", self, "_on_mag_reload_finish")

func _on_mag_reload_finish():
	reloadAudio.pitch_scale = 1	
	reloadAudio.stop()
	magReloadTimer.wait_time = reloadTime
	animationPlayer.playback_speed = 1.0
	ammo -= ammoDifference
	mag += ammoDifference
	
func cancel_reload():
	reloadAudio.pitch_scale = 1
	reloadAudio.stop()	
	magReloadTimer.wait_time = reloadTime	
	animationPlayer.playback_speed = 1.0
	magReloadTimer.stop()
	ammoDifference = 0;

func add_max_ammo():
	ammo = maxAmmoCapacity

func set_rotation(rotation):
	sprite.rotation = rotation

func set_fire_rotation(rotation):
	fire.rotation = rotation

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

func double_fire_speed():
	fire.double_fire_speed()

func normal_fire_speed():
	fire.normal_fire_speed()

func _input(event):
	if event.is_action_released("shoot"):
		if isFlamethrower:
			shootAudio.stop()
			fire.stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
