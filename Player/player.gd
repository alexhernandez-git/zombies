extends KinematicBody2D

export (PackedScene) var Bullet

var SPEED = 120

var DISTANCE_IN_FRONT = 0

onready var light = $Light2D
onready var maskedLight = $Light2D3

onready var shootPosition = $WeaponStartPositions/ShootPosition

onready var canShootTimer = $CanShootTimer

onready var interactLabel = $InteractionElements/InteractionLabel

var lightTexture = preload("res://Assets/light2rigth.png")

var lightFullTexture = preload("res://Assets/light.png")

var interactableAction = ""

var ammo = 30

var money = 500

var max_health = 100
var current_health = max_health
var regen_delay = 3.0
var regen_rate = 10.0  # Health points regenerated per second
var regen_timer = 0.0

var perks = []

onready var colorRect = $Camera2D/ColorRect

func _ready():
	Globals.connect("health_changed", self, "_on_health_changed")
	Globals.connect("money_earned", self, "_on_money_earned")
	
func _on_health_changed(damage):
	print("entra")
	
func _on_money_earned(amount):
	print("entra money")
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
	if Input.is_action_pressed("multi_build"):
		var runMultiplyer =  1.5
		if "SpeedPerk" in perks:
			runMultiplyer = 2
		currentSpeed = SPEED * runMultiplyer
	var move_direction = input_vector.normalized()
	move_and_slide(currentSpeed * move_direction)
	
	light.rotation = get_angle_to(get_global_mouse_position())
	maskedLight.rotation = get_angle_to(get_global_mouse_position())
	
	var player_direction = (get_global_mouse_position() - position).normalized()
	var target_position = global_position + player_direction * DISTANCE_IN_FRONT
	shootPosition.global_position = target_position

func _unhandled_input(event):
	if event.is_action_released("interact"):
		interact()

func shoot():
	if canShootTimer.is_stopped() and ammo > 0:
		ammo -= 1
		canShootTimer.start()
		var bullet_instance = Bullet.instance()
		add_child(bullet_instance)
		bullet_instance.global_position = shootPosition.global_position
		var target = get_global_mouse_position()
		var direction_to_mouse = bullet_instance.global_position.direction_to(target).normalized()
		bullet_instance.set_direction(direction_to_mouse)

func _regenerate_health():
	if current_health < max_health:
		current_health += regen_rate * get_process_delta_time()
		if current_health > max_health:
			current_health = max_health

func _on_hurtBox_area_entered(area):
	if "hitBox" in area.name:
		takeDamage(50)

func takeDamage(damage: int):
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
	if "RevivePerk" in perks:
		perks.erase("RevivePerk")
		current_health = max_health
		resetPerks()
	else:
		queue_free()
	
func interact():
	if interactableAction == "BuyAmmo":
		if money >= 500:
			money -= 500
			ammo += 180
	if interactableAction == "HealthPerk" and not "HealthPerk" in perks:
		if money >= 2500:
			money -= 2500
			max_health = 250
			current_health = 250
			perks.append("HealthPerk")
	if interactableAction == "RevivePerk" and not "RevivePerk" in perks:
		if money >= 500:
			money -= 500
			perks.append("RevivePerk")
	if interactableAction == "SpeedPerk" and not "SpeedPerk" in perks:
		if money >= 2000:
			money -= 2000
			perks.append("SpeedPerk")
	if interactableAction == "VisionPerk" and not "VisionPerk" in perks:
		if money >= 3000:
			money -= 3000
			$Light2D.texture = lightFullTexture
			$Light2D3.texture = lightFullTexture
			perks.append("VisionPerk")



func resetPerks():
	if "VisionPerk" in perks:
		$Light2D.texture = lightTexture
		$Light2D3.texture = lightTexture
		perks.erase("VisionPerk")
	if "HealthPerk" in perks:
		perks.erase("HealthPerk")
	if "SpeedPerk" in perks:
		perks.erase("SpeedPerk")

func _on_InteractionArea_area_entered(area):
	# Perks
	if area.name == "BuyAmmo":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Ammo: $500"
	if area.name == "HealthPerk":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Health perk: $2500"
	if area.name == "RevivePerk":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Revive perk: $500"
	if area.name == "SpeedPerk":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Speed perk: $2000"
	if area.name == "VisionPerk":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Vision perk: $3000"
	# PowerUps
	if area.name == "AtomicBomb":
		money += 400
		Globals.emit_signal("atomic_bomb_detonated")
		area.die()

func _on_InteractionArea_area_exited(area):
	if area.name == interactableAction:
		interactableAction = ""
		interactLabel.visible = false
		interactLabel.text = ""
