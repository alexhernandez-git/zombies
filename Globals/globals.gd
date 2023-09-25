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

var maxEnemeySpeed = 100

var max_spawn_timer = 5.0

var spawn_timer = 0

signal health_changed(health)
signal player_damaged(health)
signal money_earned(amount)
signal round_passed

func _process(delta):
	if remainingEnemies <= 0:
		_on_round_passed()
		Globals.emit_signal("round_passed")

func _on_round_passed():
	roundCount += 1
	remainingEnemies =  5 * roundCount
	enemyHealth = 5 * roundCount
	if enemySpeed < maxEnemeySpeed:
		enemySpeed += 10
	max_spawn_timer -= 0.4
	if max_spawn_timer < 1:
		max_spawn_timer = 1


func player_damaged(health):
	print("entra")
