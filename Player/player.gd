extends KinematicBody2D

export (PackedScene) var Bullet

var SPEED = 100

var DISTANCE_IN_FRONT = 15

onready var light = $Light2D
onready var maskedLight = $Light2D3

onready var onHandSprite = $Sprites/OnHandSprite

onready var shootPosition = $WeaponStartPositions/ShootPosition

onready var canShootTimer = $CanShootTimer

onready var canMeleTimer = $CanMeleTimer

onready var meleAnimation = $MeleAnimation

onready var restTimer = $RestTimer

onready var impulseTimer = $ImpulseTimer

onready var interactLabel = $InteractionElements/InteractionLabel

var lightTexture = preload("res://Assets/light2rigth.png")

var lightFullTexture = preload("res://Assets/light.png")

var interactableAction = ""

var max_energy = 100
var energy = max_energy
var can_run_again = true

var ammo = 30

var money = 50000

var total_health = 100
var max_health = total_health
var current_health = max_health
var regen_delay = 3.0
var regen_rate = 10.0  # Health points regenerated per second
var regen_timer = 0.0

var perks = []

var meleDamage = 100

var velocity = Vector2.ZERO

var maxMagCapacity = 30
var mag = 30

onready var colorRect = $Camera2D/ColorRect

var power_ups = []

var jump_impulse = 10000  # Adjust the jump impulse strength as needed.
var jump_duration = 0.2  # Adjust the duration of the jump impulse as needed.
var jump_timer = 0  # Timer to track the duration of the jump impulse.

func _ready():
	Globals.connect("health_changed", self, "_on_health_changed")
	Globals.connect("money_earned", self, "_on_money_earned")
	Globals.connect("max_ammo", self, "_on_max_ammo")
	
func _on_health_changed(damage):
	pass
	
func _on_money_earned(amount):
	var moneyAmount = amount
	money += moneyAmount

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	var rColor = 255 - ((current_health * 100 / max_health) * 255 / 100)
	if rColor > 255:
		rColor = 255
	var aColor = rColor
	if aColor > 180:
		aColor = 180
	colorRect.modulate = Color8(rColor,32,32,aColor)
	
	if current_health < max_health:
		regen_timer += delta
	if regen_timer >= 3:
		current_health += 1
		if current_health > max_health:
			current_health = max_health
			regen_timer = 0

	if Input.is_action_pressed("shoot"):
		shoot()
	
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var currentSpeed = SPEED

	if "Speed" in perks:
		if can_run_again and Input.is_action_pressed("multi_build"):
			if energy == 0:
				can_run_again = false
			else:
				energy -= 1
			restTimer.start()
			var runMultiplyer =  1.4
			currentSpeed = SPEED * runMultiplyer
		else:
			if restTimer.is_stopped() and energy < max_energy:
				can_run_again = true
				energy += 1
		
	var move_direction = input_vector.normalized()
	velocity = currentSpeed * move_direction
	
	if "Impulse" in perks and impulseTimer.is_stopped() and Input.is_action_just_pressed("jump"):
		print("entra")
		jump_timer = jump_duration  # Start the jump timer.
		impulseTimer.start()

	if jump_timer > 0:
		velocity += input_vector * jump_impulse * delta  # Gradually apply the impulse.
		jump_timer -= delta

		
	velocity = move_and_slide(velocity)
	
	light.rotation = get_angle_to(get_global_mouse_position())
	maskedLight.rotation = get_angle_to(get_global_mouse_position())
	var player_direction = (get_global_mouse_position() - position).normalized()
	var target_position = global_position + player_direction * DISTANCE_IN_FRONT
	var angle = get_angle_to(target_position)
	onHandSprite.rotation = angle
	print(onHandSprite.rotation_degrees)

	if onHandSprite.rotation_degrees < -90 or onHandSprite.rotation_degrees > 90:
		onHandSprite.flip_v = true
	else:
		onHandSprite.flip_v = false
		print("right")

	onHandSprite.global_position = target_position
	shootPosition.global_position = target_position


func _input(event):
	if event.is_action_pressed("mele"):
		mele()
	if event.is_action_pressed("reload"):
		print("entra")
		reload()

func _unhandled_input(event):
	if event.is_action_released("interact"):
		interact()

func shoot():
	if canShootTimer.is_stopped():
		if not "UnlimitedFire" in power_ups:
			if ammo == 0:
				return
			if mag > 0:
				mag -= 1
			else:
				reload()
		canShootTimer.start()
		var bullet_instance = Bullet.instance()
		add_child(bullet_instance)
		bullet_instance.global_position = shootPosition.global_position
		var target = get_global_mouse_position()
		var direction_to_mouse = global_position.direction_to(target).normalized()
		bullet_instance.set_direction(direction_to_mouse)
		var angle = deg2rad(45)
		var right_direction = direction_to_mouse.rotated(angle)
		var left_direction = direction_to_mouse.rotated(-angle)
		if ("MultipleWeapons" in power_ups):
			for direction in ["UpLeft", "UpRight"]:
				var new_direction
				if (direction == "UpLeft"):
					new_direction = (direction_to_mouse + left_direction).normalized()
				if (direction == "UpRight"):
					new_direction = (direction_to_mouse + right_direction).normalized()
				print(new_direction)
				var seccond_bullet_instance = Bullet.instance()
				add_child(seccond_bullet_instance)
				seccond_bullet_instance.global_position = shootPosition.global_position
				seccond_bullet_instance.set_direction(new_direction)

func reload():
	if ammo > 0 and mag < maxMagCapacity:
		var ammoDifference = maxMagCapacity - mag
		if ammo < ammoDifference:
			ammoDifference = ammo  # Lower the ammoDifference if ammo is less than the calculated difference
		ammo -= ammoDifference
		mag += ammoDifference

func mele():
	if canMeleTimer.is_stopped():
		meleAnimation.play("mele")

func _regenerate_health():
	if current_health < max_health:
		current_health += regen_rate * get_process_delta_time()
		if current_health > max_health:
			current_health = max_health

func _on_hurtBox_area_entered(area):
	if "hitBox" in area.name:
		print("entra")
		takeDamage(50)


func _on_Mele_area_entered(area):
	if "hitBox" in area.name:
		print("entra mele area")
		area.get_parent().takeDamage(meleDamage, true)

func takeDamage(damage: int):
	if "Invincibility" in power_ups:
		return
	current_health -= damage
	Globals.emit_signal("health_changed", damage)
	if current_health <= 0:
		current_health = 0
		die()
	else:
		regen_timer = 0
		$Timer.stop()
		$Timer.start()

func die():
	if "Revive" in perks:
		perks.erase("Revive")
		current_health = max_health
		resetPerks()
	else:
		queue_free()
	
func interact():
	if interactableAction == "BuyAmmo":
		if money >= 500:
			money -= 500
			ammo += 180
	if perks.size() < 4:
		if interactableAction == "Health" and not "Health" in perks:
			if money >= 2500:
				money -= 2500
				max_health = 250
				current_health = 250
				perks.append("Health")
		if interactableAction == "Revive" and not "Revive" in perks:
			if money >= 500:
				money -= 500
				perks.append("Revive")
		if interactableAction == "Speed" and not "Speed" in perks:
			if money >= 2000:
				money -= 2000
				perks.append("Speed")
		if interactableAction == "Impulse" and not "Impulse" in perks:
			if money >= 2000:
				money -= 2000
				perks.append("Impulse")
		if interactableAction == "QuickFire" and not "QuickFire" in perks:
			if money >= 2500:
				money -= 2500
				canShootTimer.wait_time = canShootTimer.wait_time / 2
				perks.append("QuickFire")



func resetPerks():
	if "Health" in perks:
		max_health = total_health
		perks.erase("Health")
	if "Speed" in perks:
		perks.erase("Speed")
	if "Impulse" in perks:
		perks.erase("Impulse")
	if "QuickFire" in perks:
		canShootTimer.wait_time = canShootTimer.wait_time * 2
		perks.erase("QuickFire")

func _on_InteractionArea_area_entered(area):
	# Perks
	if area.name == "BuyAmmo":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Ammo: $500"
	if area.name == "Health":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Health perk: $2500"
	if area.name == "Revive":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Revive perk: $500"
	if area.name == "Speed":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Speed perk: $2000"
	if area.name == "Impulse":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Impulse perk: $2000"
	if area.name == "QuickFire":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Quick fire perk: $2500"
		
	# PowerUps
	if "AtomicBomb" in area.name:
		Globals.atomic_bomb = true
		money += 400
		Globals.emit_signal("atomic_bomb_detonated")
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timeout_atomic_bomb")
		timer.wait_time = 5
		timer.one_shot = true
		add_child(timer)
		timer.start()
		area.die()
	if "MaxAmmo" in area.name:
		Globals.emit_signal("max_ammo")
		area.die()
	if "Vision" in area.name:
		power_ups.append("Vision")
		$Light2D.texture = lightFullTexture
		$Light2D3.texture = lightFullTexture
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timeout_vision")
		timer.wait_time = Globals.power_up_wait_time
		timer.one_shot = true
		add_child(timer)
		timer.start()
		area.die()
	if "InstantKill" in area.name:
		Globals.global_power_ups.append("InstantKill")
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timeout_instant_kill")
		timer.wait_time = Globals.power_up_wait_time
		timer.one_shot = true
		add_child(timer)
		timer.start()
		area.die()
	if "Invincibility" in area.name:
		power_ups.append("Invincibility")
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timeout_invincibility")
		timer.wait_time = Globals.power_up_wait_time
		timer.one_shot = true
		add_child(timer)
		timer.start()
		area.die()
	if "UnlimitedFire" in area.name:
		power_ups.append("UnlimitedFire")
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timeout_unlimited_fire")
		timer.wait_time = Globals.power_up_wait_time
		timer.one_shot = true
		add_child(timer)
		timer.start()
		area.die()
	if "MultipleWeapons" in area.name:
		power_ups.append("MultipleWeapons")
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timeout_multiple_weapons")
		timer.wait_time = Globals.power_up_wait_time
		timer.one_shot = true
		add_child(timer)
		timer.start()
		area.die()


func _on_max_ammo():
	ammo += 180

func _on_timeout_atomic_bomb(): 
	Globals.atomic_bomb = false

func _on_timeout_vision():
	power_ups.erase("Vision")
	if not "Vision" in power_ups:
		$Light2D.texture = lightTexture
		$Light2D3.texture = lightTexture

func _on_timeout_instant_kill():
	Globals.global_power_ups.erase("InstantKill")

func _on_timeout_invincibility():
	power_ups.erase("Invincibility")
	
func _on_timeout_unlimited_fire():
	power_ups.erase("UnlimitedFire")

func _on_timeout_multiple_weapons():
	power_ups.erase("MultipleWeapons")

func _on_InteractionArea_area_exited(area):
	if area.name == interactableAction:
		interactableAction = ""
		interactLabel.visible = false
		interactLabel.text = ""

