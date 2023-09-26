extends Node


# Perks = Health | Revive | Fast Fire | Reload protection | Fast reload | Slide 
# Power Up = Max Amo | Triple Weapon | Invencibility | Nuclear Bomb | Unlimited fire | Clear vision
# Weapons = Gun | AR | Subfusil | Sniper | Lanzacoetes  | Mini gun | Arrow
# Granades = Granade | Fire |
# Cuerpo a cuerpo = Knife 
# Especials = Hammer | Agujero negro | Desintegrador | Teleport gun | Lanzallamas 
# Slide boots
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var power_ups = ["AtomicBomb", "MaxAmmo", "Vision", "InstantKill", "Invincibility", "UnlimitedFire", "MultipleWeapons"]

var roundCount = 1

var enemyHealth = 10

var remainingEnemies = 5

var enemySpeed = 50

var spawn_timer = 0

export var maxEnemeySpeed = 100

export var max_spawn_timer = 5.0

export var startingRound = 0

var difficulty =  10

var enemyHitSpeed = 1

var enemyHitMoney = 10

var enemyKillMoney = 50

var enemyKillMoneyMele = 100

var instantKill = false

var power_up_wait_time = 15

var power_up_probability = 10

var atomic_bomb = false


signal health_changed(health)
signal player_damaged(health)
signal money_earned(amount)
signal atomic_bomb_detonated
signal enemy_died(position)
signal round_passed
signal enemy_damage(position)

func _ready():
	enemyHitSpeed = difficulty_difference(enemyHitSpeed)
	
	for i in range(startingRound):
	  _on_round_passed()
	

func _process(delta):
	if remainingEnemies <= 0:
		_on_round_passed()
		Globals.emit_signal("round_passed")

func difficulty_difference(amount: float) -> float:
	return amount + (difficulty * amount / 10)

func difficulty_difference_substract(amount: float) -> float:
	return amount - (difficulty * amount / 10)

func _on_round_passed():
	roundCount += 1
	remainingEnemies =  2 * roundCount
	enemyHealth = 5 * roundCount
	if enemySpeed < maxEnemeySpeed:
		enemySpeed += difficulty_difference(5)
	max_spawn_timer -= difficulty_difference(0.4)
	if max_spawn_timer < difficulty_difference_substract(1):
		max_spawn_timer = 1


func player_damaged(health):
	print("entra")
