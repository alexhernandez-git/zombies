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

onready var audioPlayer = $"../Listener2D/AudioStreamPlayer2D2"
onready var finsihRoundPlayer = $FinishRoundPlayer
onready var bodySprite = $Sprites/Body

var lightTexture = preload("res://Assets/light2rigth.png")

var lightFullTexture = preload("res://Assets/light.png")

var grenade_scene = preload("res://Player/grenade.tscn")

var interactableAction = ""
var interactableNode

var max_energy = 500
var energy = max_energy
var can_run_again = true

var ammo = 30

var money = 500

var maxThrowableObjectCapacity = 0
var throwableObjectAmount = 0

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

onready var colorRect = $"../Camera2D/ColorRect"

onready var animation = $AnimationPlayer

onready var weapon_manager = $WeaponManager

onready var throwableSprite = $Sprites/Throwable

var throwableObject = "Grenade"

var power_ups = []

var jump_impulse = 10000  # Adjust the jump impulse strength as needed.
var jump_duration = 0.2  # Adjust the duration of the jump impulse as needed.
var jump_timer = 0  # Timer to track the duration of the jump impulse.

var gun

var hit_feed = 0

var supplies = 1

var throwing = false

const Players: String = "Players"

var unlocked_weapons = [ 
	"Pistol", 
	"", 
	"",
	"", 
	"", 
	"", 
	"", 
	"", 
	"", 
	"", 
	"", 
	"", 
	"", 
	"", 
	"" 
]

#var unlocked_weapons = ["Pistol", "", "", "" ]
#var unlocked_perks = ["", "", "", "", "", "", "", ""]
var unlocked_perks = ["", "", "", "", "", "", "", ""]
var round_arrived = 0
func _init() -> void:
	add_to_group(Players)

func _ready():
	var file = File.new()
	file.open("user_data.dat", File.READ)
	var player_data = file.get_var()
	if player_data:
		if "unlocked_weapons" in player_data and player_data["unlocked_weapons"].size() > 0:
			unlocked_weapons = player_data["unlocked_weapons"]
		if "unlocked_perks" in player_data and player_data["unlocked_perks"].size() > 0:
			unlocked_perks = player_data["unlocked_perks"]
		if "round_arrived" in player_data and player_data["round_arrived"]:
			round_arrived = player_data["round_arrived"]
	file.close()

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
	print("entra 1")
	print(Globals.roundCount + 1)
	#if Globals.roundCount % 5 == 0:  # Check if i is a multiple of 5
	print("entra 2")

	var itemCount = min(floor(Globals.roundCount / 5 ), Globals.perks.size())
	print(itemCount)
	var available_items = []
	available_items.append_array(Globals.perks.slice(0, itemCount))
	itemCount = min(floor(Globals.roundCount / 5) , Globals.weapons.size())
	available_items.append_array(Globals.weapons.slice(0, itemCount))
	print(available_items)		
	var random_index = randi() % available_items.size()
	print(random_index)		
	Globals.emit_signal("call_supplies", global_position, available_items[random_index])

	audioPlayer.stop()
	finsihRoundPlayer.play()

func _on_round_passed():
	money += Globals.roundCount * 100
	finsihRoundPlayer.stop()
	if Globals.roundCount % 5 == 0 and Globals.roundCount > round_arrived:
		round_arrived = Globals.roundCount
	var file = File.new()
	file.open("user_data.dat", File.WRITE)
	file.store_var({
	"unlocked_perks": unlocked_perks,
	"unlocked_weapons": unlocked_weapons,
	"round_arrived": round_arrived
	})
	file.close()
	audioPlayer.play()
	supplies += 1
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
				energy += 5
		
	var move_direction = input_vector.normalized()
	velocity = currentSpeed * move_direction
	
	if "Impulse" in perks and impulseTimer.is_stopped() and Input.is_action_just_pressed("jump"):
		jump_timer = jump_duration  # Start the jump timer.
		impulseTimer.start()

	if jump_timer > 0:
		velocity += input_vector * jump_impulse * delta  # Gradually apply the impulse.
		jump_timer -= delta

		
	velocity = move_and_slide(velocity)
	var player_direction = (get_global_mouse_position() - position)
	if throwing:
		player_direction = -player_direction

	var distance = player_direction.length()

	# Set a multiplier for the position change based on the distance
	var position_multiplier = 1.0 / (distance + 500.0)  # You can adjust this value

	# You can use this multiplier to increase or decrease the position change
	throwableSprite.global_position = global_position - player_direction * (distance * position_multiplier)

	player_direction = player_direction.normalized()
	
	var target_position = global_position + player_direction * DISTANCE_IN_FRONT
	var angle = get_angle_to(target_position)
	light.rotation = angle
	maskedLight.rotation = angle
	var angle_sum = -45
	if player_direction.x < 0:
		angle_sum = 45
		weaponManager.set_flip_v(true)
		bodySprite.flip_h = true
		if jump_timer > 0:
			if velocity.x > 0: 
				animation.play("impulse_left")
			else:
				animation.play("impulse_right")
		else:
			if velocity.x > 0 or velocity.x == 0 and velocity.y > 0: 
				animation.play("walk_left")
			elif velocity.x < 0 or velocity.x == 0 and velocity.y < 0:
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
			if velocity.x > 0 or velocity.x == 0 and velocity.y > 0: 
				animation.play("walk_right")
			elif velocity.x < 0 or velocity.x == 0 and velocity.y < 0:
				animation.play("walk_left")
			else:
				animation.play("RESET")
		
		weaponManager.set_flip_v(false)
		bodySprite.flip_h = false

	angle += deg2rad(angle_sum)
	weaponManager.set_rotation(angle)
	weaponManager.set_end_of_gun_position(global_position, player_direction)
	weaponManager.set_gun_position(global_position, player_direction)


func _input(event):
	if event.is_action_pressed("mele"):
		mele()
	if event.is_action_pressed("throw_object"):
		if throwableObjectAmount == 0 or not "UnlimitedFire" in Globals.power_ups:
			return
		print(throwableObjectAmount)
		throwing = true
		throwableSprite.frame = Globals.weapons_data[throwableObject].frame
		throwableSprite.visible = true
		weapon_manager.visible = false
	if event.is_action_released("throw_object"):
		if throwableObjectAmount == 0 or not "UnlimitedFire" in Globals.power_ups:
			return
		print(throwableObjectAmount)
		throwing = false
		weapon_manager.visible = true
		throwableSprite.visible = false
		throw_object()
	if event.is_action_released("call_supplies"):
		call_supplies()
	if event.is_action_pressed("ui_pause"):
		Globals.emit_signal("paused")
		get_tree().paused = true
	if event.is_action_released("interact"):
		interact()
		
func call_supplies(supply = null):
	if supplies > 0:
		Globals.emit_signal("call_supplies", global_position, supply)
		supplies -= 1

func reload():
	if ammo > 0 and mag < maxMagCapacity:
		var ammoDifference = maxMagCapacity - mag
		if ammo < ammoDifference:
			ammoDifference = ammo  # Lower the ammoDifference if ammo is less than the calculated difference
		ammo -= ammoDifference
		mag += ammoDifference

func throw_object():
	if throwableObjectAmount == 0 or not "UnlimitedFire" in Globals.power_ups:
		return
	var grenade = grenade_scene.instance() as RigidBody2D
	var player_direction = -(get_global_mouse_position() - position)
	var distance = player_direction.length()
	var speed_scaling_factor = 1000.0 / (distance + 100.0)  # Adjust this factor as needed
	var speed = grenade.speed * (distance / speed_scaling_factor + 1.0)
	if not "UnlimitedFire" in Globals.global_power_ups:
		throwableObjectAmount -= 1
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
	if "Buy" in interactableAction:
		print(interactableAction)
		if "Trowable" in interactableAction:
			var trowable_object_name = interactableAction.substr("BuyTrowable".length())
			if not trowable_object_name in unlocked_weapons:
				for index in Globals.weapons.size():
					if trowable_object_name == Globals.weapons[index]:
						unlocked_weapons[index] = trowable_object_name
						Globals.emit_signal("unlocked_gun")
						var file = File.new()
						file.open("user_data.dat", File.WRITE)
						file.store_var({
						"unlocked_perks": unlocked_perks,
						"unlocked_weapons": unlocked_weapons,
						"round_arrived": round_arrived
						})
						file.close()
			var currentTrowableObject = false
			if throwableObject == trowable_object_name:
					currentTrowableObject = true
			if currentTrowableObject:
				if money >= Globals.weapons_data[trowable_object_name].ammoPrice and throwableObjectAmount < maxThrowableObjectCapacity:
					money -= Globals.weapons_data[trowable_object_name].ammoPrice
					throwableObjectAmount = maxThrowableObjectCapacity
			else:
				if money >= Globals.weapons_data[trowable_object_name].price:
					money -= Globals.weapons_data[trowable_object_name].price
					throwableObject = trowable_object_name
					throwableObjectAmount = Globals.weapons_data[trowable_object_name].maxAmmo
					maxThrowableObjectCapacity = Globals.weapons_data[trowable_object_name].maxAmmo
					
		elif "Weapon" in interactableAction:
			var weapon_name = interactableAction.substr("BuyWeapon".length())
			if not weapon_name in unlocked_weapons:
				for index in Globals.weapons.size():
					if weapon_name == Globals.weapons[index]:
						unlocked_weapons[index] = weapon_name
						Globals.emit_signal("unlocked_gun")
						var file = File.new()
						file.open("user_data.dat", File.WRITE)
						file.store_var({
						"unlocked_perks": unlocked_perks,
						"unlocked_weapons": unlocked_weapons,
						"round_arrived": round_arrived
						})
						file.close()
			var currentWeapon = false
			for gun in weaponManager.active_weapons:
				print(gun.name)
				if gun.name == weapon_name:
					currentWeapon = true
			if currentWeapon:
				if money >= Globals.weapons_data[weapon_name].ammoPrice and not weaponManager._is_gun_full_ammo(weapon_name):
					money -= Globals.weapons_data[weapon_name].ammoPrice	
					weaponManager.add_ammo(weapon_name)
			else:
				if money >= Globals.weapons_data[weapon_name].price:
					money -= Globals.weapons_data[weapon_name].price
					weaponManager.add_weapon(weapon_name)
	if interactableAction in Globals.perks:
		if not interactableAction in unlocked_perks:
			for index in Globals.perks.size():
				if interactableAction == Globals.perks[index]:
					unlocked_perks[index] = interactableAction
					Globals.emit_signal("unlocked_perk")
					var file = File.new()
					file.open("user_data.dat", File.WRITE)
					file.store_var({
						"unlocked_perks": unlocked_perks,
						"unlocked_weapons": unlocked_weapons,
						"round_arrived": round_arrived
					})
					file.close()
	if perks.size() < 4:
		if interactableAction == "Health" and not "Health" in perks:
			if money >= interactableNode.price:
				money -= interactableNode.price
				max_health = 200
				current_health = 200
				perks.append("Health")
		if interactableAction == "Revive" and not "Revive" in perks:
			if money >= interactableNode.price:
				money -= interactableNode.price
				perks.append("Revive")
		if interactableAction == "Speed" and not "Speed" in perks:
			if money >= interactableNode.price:
				money -= interactableNode.price
				perks.append("Speed")
		if interactableAction == "Impulse" and not "Impulse" in perks:
			if money >= interactableNode.price:
				money -= interactableNode.price
				perks.append("Impulse")
		if interactableAction == "FastMag" and not "FastMag" in perks:
			if money >= interactableNode.price:
				money -= interactableNode.price
				perks.append("FastMag")
		if interactableAction == "QuickFire" and not "QuickFire" in perks:
			if money >= interactableNode.price:
				money -= interactableNode.price
				weaponManager.current_weapon.set_attack_cooldown_wait_time(
					weaponManager.current_weapon.get_attack_cooldown_wait_time() / 2
				)
				perks.append("QuickFire")
		if interactableAction == "Critical" and not "Critical" in perks:
			if money >= interactableNode.price:
				money -= interactableNode.price
				perks.append("Critical")
		if interactableAction == "MoreWeapons" and not "MoreWeapons" in perks:
			if money >= interactableNode.price:
				money -= interactableNode.price
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
	# Perks
	if not area:
		return
	
	if "BuyWeapon" in area.name:
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
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Granades: $500"
	if area.name == "Health":
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Health perk: $2500"
	if area.name == "Revive":
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Revive perk: $1500"
	if area.name == "Speed":
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Speed perk: $2000"
	if area.name == "Impulse":
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Impulse perk: $2000"
	if area.name == "QuickFire":
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Quick fire perk: $2500"
	if area.name == "FastMag":
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Fast mag perk: $3000"
	if area.name == "Critical":
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - Critical perk: $4000"
	if area.name == "MoreWeapons":
		interactableNode = area
		interactableAction = area.name
		interactLabel.visible = true
		interactLabel.text = "Press E - More weapons perk: $4000"
		
	# PowerUps
	if "AtomicBomb" in area.name:
		if "DoublePoints" in Globals.global_power_ups:
			money += 800
		else:
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
		weaponManager.duplicate_current()
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
		
	if "Horde" in area.name:
		Globals.global_power_ups.append("Horde")
		var timer = Timer.new()
		timer.connect("timeout",self,"_on_timeout_horde")
		timer.wait_time = Globals.power_up_wait_time
		timer.one_shot = true
		add_child(timer)
		timer.start()
		area.die()
	
	if "Supplies" in area.name:
		Globals.emit_signal("call_supplies", global_position, null)
		area.queue_free()

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
	if not "MultipleWeapons" in power_ups:
		weaponManager.remove_mirror_weapon()

func _on_timeout_double_points():
	power_ups.erase("DoublePoints")

func _on_timeout_horde():
	Globals.global_power_ups.erase("Horde")
	Globals.emit_signal("horde_finished")

func _on_atomic_bomb():
	Globals.emit_signal("money_earned", Globals.atomic_bomb_money)

func _on_InteractionArea_area_exited(area):
	if area and area.name == interactableAction:
		interactableAction = ""
		interactLabel.visible = false
		interactLabel.text = ""

