extends Node


# Perks = Health | Revive | Fast Fire | Reload protection | Fast reload | Slide 
# Power Up = Max Amo | Triple Weapon | Invencibility | Nuclear Bomb | Unlimited fire | Clear vision

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var roundCount = 1

var enemyHealth = 10

var remainingEnemies = 5

var enemySpeed = 50

var spawn_timer = 0

export var maxEnemeySpeed = 100

export var max_spawn_timer = 5.0

export var startingRound = 0


var difficulty =  2

var enemyHitSpeed = 1 * difficulty

var enemyHitMoney = 10 * difficulty

var enemyKillMoney = 50 * difficulty

signal health_changed(health)
signal player_damaged(health)
signal money_earned(amount)
signal atomic_bomb_detonated
signal enemy_died(position)
signal round_passed

func _ready():
	for i in range(startingRound):
	  _on_round_passed()
	

func _process(delta):
	if remainingEnemies <= 0:
		_on_round_passed()
		Globals.emit_signal("round_passed")

func _on_round_passed():
	roundCount += 1
	remainingEnemies =  (2 * difficulty) * roundCount
	enemyHealth = (5 * difficulty) * roundCount
	if enemySpeed < maxEnemeySpeed:
		enemySpeed += (5 * difficulty)
	max_spawn_timer -= (0.4 * difficulty)
	if max_spawn_timer < (1 / difficulty):
		max_spawn_timer = 1


func player_damaged(health):
	print("entra")
