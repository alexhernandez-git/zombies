extends Node


# Perks = Health | Revive | Fast Fire | Reload protection | Fast reload | Slide 
# Weapons = Gun | AR | Subfusil | Sniper | Lanzacoetes  | Mini gun | Arrow
# Granades = Granade | Fire |
# Cuerpo a cuerpo = Knife | Hacha | Espada | Bate
# Especials = Hammer | Agujero negro | Desintegrador | Teleport gun | Lanzallamas | Tomahawk
# Slide boots
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# TODO delay time when a round is done

# Todo do maps and a arena that you can use everything that you get from the maps

var game_paused = false

var power_ups = ["AtomicBomb", "MaxAmmo", "Vision", "InstantKill", "Invincibility", "UnlimitedFire", "MultipleWeapons"]

var global_power_ups = []

var roundCount = 1

var enemyAutoIncremental = 1

var enemyHealth = 50

var remainingEnemies = 5

var enemySpeed = 50

var spawn_timer = 0

export var maxEnemeySpeed = 101

export var max_spawn_timer = 3.0

export var startingRound = 40

var difficulty =  10

var enemyHitSpeed = 1

var enemyHitMoney = 10

var enemyKillMoney = 50

var enemyCriticalKillMoney = 100

var critical_probability = 100

var enemyKillMoneyMele = 100

var instantKill = false

var power_up_wait_time = 15

var power_up_probability = remainingEnemies

var atomic_bomb = false

var item_data: Dictionary

var is_round_started = true

signal health_changed(health)
signal player_damaged(health)
signal money_earned(amount)
signal atomic_bomb
signal enemy_died(position)
signal round_finished
signal round_passed
signal enemy_damage(position)
signal max_ammo
signal paused 
signal trow_object

func _ready():
	for i in range(startingRound):
		_on_round_finished()
		_on_round_start()

func _input(event):
	if event.is_action_pressed("ui_pause"):
		emit_signal("paused")
		get_tree().paused = true

func difficulty_difference(amount: float) -> float:
	return amount + (difficulty * amount / 10)

func difficulty_difference_substract(amount: float) -> float:
	return amount - (difficulty * amount / 10)

func _on_round_finished():
	is_round_started = false
	roundCount += 1
	remainingEnemies =  int(round(10 + (roundCount * 2)))
	power_up_probability = remainingEnemies
	#critical_probability = int(round(10 + (roundCount * 2)))
	if roundCount < 5:
		enemyHealth += 100
	else:
		enemyHealth = enemyHealth * 1.1
	if enemySpeed < maxEnemeySpeed:
		enemySpeed += difficulty_difference(5)
	max_spawn_timer -= 0.2
	if max_spawn_timer < 0.4:
		max_spawn_timer = 0.4

func _on_round_start():
	is_round_started = true
