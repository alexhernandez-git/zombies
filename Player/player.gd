extends KinematicBody2D
class_name Player
export (PackedScene) var Bullet

var SPEED = 100

var DISTANCE_IN_FRONT = 15

onready var light = $Light2D
onready var maskedLight = $Light2D3

onready var canMeleTimer = $CanMeleTimer

onready var meleAnimation = $MeleAnimation

onready var restTimer = $RestTimer

onready var impulseTimer = $ImpulseTimer

onready var interactLabel = $InteractionElements/InteractionLabel

onready var weaponManager = $WeaponManager

onready var audioPlayer = $AudioStreamPlayer2D
onready var finsihRoundPlayer = $FinishRoundPlayer
onready var bodySprite = $Sprites/Body

var lightTexture = preload("res://Assets/light2rigth.png")

var lightFullTexture = preload("res://Assets/light.png")

var grenade_scene = preload("res://Player/grenade.tscn")

var interactableAction = ""
var interactableNode

var max_energy = 100
var energy = max_energy
var can_run_again = true

var ammo = 30

var money = 50000

var maxGranadesCapacity = 3
var granades = 3

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

onready var animation = $AnimationPlayer

var power_ups = []

var jump_impulse = 10000  # Adjust the jump impulse strength as needed.
var jump_duration = 0.2  # Adjust the duration of the jump impulse as needed.
var jump_timer = 0  # Timer to track the duration of the jump impulse.

var gun

var hit_feed = 0

const Players: String = "Players"

func _init() -> void:
	add_to_group(Players)

func _ready():
	gun= weaponManager.get_current_weapon()
	Globals.connect("round_finished", self, "_on_round_finished")
	Globals.connect("round_passed", self, "_on_round_passed")
	Globals.connect("health_changed", self, "_on_health_changed")
	Globals.connect("money_earned", self, "_on_money_earned")
	Globals.connect("atomic_bomb", self, "_on_atomic_bomb")
	
func _on_health_changed(damage):
	pass
	
func _on_money_earned(amount):
	var moneyAmount = amount
	if "DoublePoints" in Globals.global_power_ups:
		moneyAmount *= 2
	money += moneyAmount

func _on_round_finished():
	audioPlayer.stop()
	finsihRoundPlayer.play()

func _on_round_passed():
	money += Globals.roundCount * 100
	granades = maxGranadesCapacity
	finsihRoundPlayer.stop()
	audioPlayer.play()
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
			animation.playback_speed = 1.4
			currentSpeed = SPEED * runMultiplyer
		else:
			animation.playback_speed = 1
			if restTimer.is_stopped() and energy < max_energy:
				can_run_again = true
				energy += 1
		
	var move_direction = input_vector.normalized()
	velocity = currentSpeed * move_direction
	
	if "Impulse" in perks and impulseTimer.is_stopped() and Input.is_action_just_pressed("jump"):
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
	var angle_sum = -45
	if player_direction.x < 0:
		angle_sum = 45
		weaponManager.current_weapon.set_flip_v(true)
		bodySprite.flip_h = true
		if jump_timer > 0:
			if velocity.x > 0: 
				animation.play("impulse_left")
			else:
				animation.play("impulse_right")
		else:
			if velocity.x > 0 or velocity.y > 0: 
				animation.play("walk_left")
			elif velocity.x < 0 or velocity.y < 0:
				animation.play("walk_right")
			else:
				animation.play("RESET")
	else:
		if jump_timer > 0:
			if velocity.x > 0: 
				animation.play("impulse_right")
			else:
				animation.play("impulse_left")
		else:
			if velocity.x > 0 or velocity.y > 0: 
				animation.play("walk_right")
			elif velocity.x < 0 or velocity.y < 0:
				animation.play("walk_left")
			else:
				animation.play("RESET")
		
		weaponManager.current_weapon.set_flip_v(false)
		bodySprite.flip_h = false
		
	angle += deg2rad(angle_sum)
	weaponManager.current_weapon.set_rotation(angle)
	weaponManager.current_weapon.set_end_of_gun_position(global_position, player_direction)
	weaponManager.current_weapon.set_gun_position(global_position, player_direction)
	


func _input(event):
	if event.is_action_pressed("mele"):
		mele()
	if event.is_action_released("throw_object"):
		throw_object()
		
func _unhandled_input(event):
	if event.is_action_released("interact"):
		interact()

func reload():
	if ammo > 0 and mag < maxMagCapacity:
		var ammoDifference = maxMagCapacity - mag
		if ammo < ammoDifference:
			ammoDifference = ammo  # Lower the ammoDifference if ammo is less than the calculated difference
		ammo -= ammoDifference
		mag += ammoDifference

func throw_object():
	if granades == 0:
		return
	var grenade = grenade_scene.instance() as RigidBody2D
	var player_direction = (get_global_mouse_position() - position)
	var distance = player_direction.length()
	var speed_scaling_factor = 10.0  # Adjust this factor as needed
	var speed = grenade.speed * (distance / speed_scaling_factor + 1.0)
	granades -= 1
	Globals.emit_signal("trow_object", global_position, player_direction.normalized() ,  speed, grenade)
	pass

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
		takeDamage(50)


func _on_Mele_area_entered(area):
	if "hitBox" in area.name:
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
	if  "BuyWeapon" in interactableAction:
		var currentGun = false
		if not interactableNode or not "gun" in interactableNode:
			return
		print("entra")
		for gun in weaponManager.active_weapons:
			if gun.name == interactableNode.gun:
				currentGun = true
		if currentGun:
			print("entra1")
			if money >= interactableNode.ammoPrice and not weaponManager._is_gun_full_ammo(interactableNode.gun):
				money -= interactableNode.ammoPrice
				weaponManager.add_ammo(interactableNode.gun)
		else:
			if money >= interactableNode.price:
				money -= interactableNode.price
				weaponManager.add_weapon(interactableNode.gun)
	if interactableAction == "BuyGranades":
		if money >= 500:
			if granades < maxGranadesCapacity:
				money -= 500
				granades = maxGranadesCapacity
	if perks.size() < 4:
		if interactableAction == "Health" and not "Health" in perks:
			if money >= 2500:
				money -= 2500
				max_health = 200
				current_health = 200
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
		if interactableAction == "FastMag" and not "FastMag" in perks:
			if money >= 3000:
				money -= 3000
				perks.append("FastMag")
		if interactableAction == "QuickFire" and not "QuickFire" in perks:
			if money >= 2500:
				money -= 2500
				weaponManager.current_weapon.set_attack_cooldown_wait_time(
					weaponManager.current_weapon.get_attack_cooldown_wait_time() / 2
				)
				perks.append("QuickFire")
		if interactableAction == "Critical" and not "Critical" in perks:
			if money >= 4000:
				money -= 4000
				perks.append("Critical")
		if interactableAction == "MoreWeapons" and not "MoreWeapons" in perks:
			if money >= 4000:
				money -= 4000
				perks.append("MoreWeapons")

func resetPerks():
	if "Health" in perks:
		max_health = total_health
		perks.erase("Health")
	if "Speed" in perks:
		perks.erase("Speed")
	if "Impulse" in perks:
		perks.erase("Impulse")
	if "FastMag" in perks:
		perks.erase("FastMag")
	if "Critical" in perks:
		perks.erase("Critical")
	if "QuickFire" in perks:
		weaponManager.current_weapon.set_attack_cooldown_wait_time(
			weaponManager.current_weapon.get_attack_cooldown_wait_time() * 2
		)
		perks.erase("QuickFire")
	if "MoreWeapons" in perks:
		weaponManager.delete_remaining_weapons()
		perks.erase("MoreWeapons")

func _on_InteractionArea_area_entered(area):
	print(area)
	# Perks
	if not area:
		return
		
	if "BuyWeapon" in area.name:
		print("entra")
		interactableNode = area
		var currentGun = false
		for gun in weaponManager.active_weapons:
			if gun.name == area.gun:
				currentGun = true
		if currentGun:
			interactableAction = area.name
			interactLabel.visible = true
			interactLabel.text = str("Press E - Buy ammo: ", area.ammoPrice)
		else:
			interactableAction = area.name
			interactLabel.visible = true
			interactLabel.text = str("Press E - ", area.gun , ": ", area.price)
	if area.name == "BuyGranades":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Granades: $500"
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
	if area.name == "FastMag":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Fast mag perk: $3000"
	if area.name == "Critical":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Critical perk: $4000"
	if area.name == "MoreWeapons":
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - More weapons perk: $4000"
		
	# PowerUps
	if "AtomicBomb" in area.name:
		money += 400
		Globals.emit_signal("atomic_bomb")
		var timer = Timer.new()
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
		
	if "DoublePoints" in area.name:
		power_ups.append("DoublePoints")
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timeout_double_points")
		timer.wait_time = Globals.power_up_wait_time
		timer.one_shot = true
		add_child(timer)
		timer.start()
		area.die()

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

func _on_timeout_double_points():
	power_ups.erase("DoublePoints")

func _on_atomic_bomb():
	Globals.emit_signal("money_earned", Globals.atomic_bomb_money)

func _on_InteractionArea_area_exited(area):
	print(str("entra exit", area))
	if area and area.name == interactableAction:
		interactableAction = ""
		interactLabel.visible = false
		interactLabel.text = ""

