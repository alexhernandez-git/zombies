extends Node


# Perks = Health | Revive | Fast Fire | Reload protection | Fast reload | Slide 
# Power Up = Max Amo | Triple Weapon | Invencibility | Nuclear Bomb | Unlimited fire | Clear vision

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var roundCount = 0

var enemyHealth = 10

var remainingEnemies = 10

var enemySpeed = 50

var maxEnemeySpeed = 100

var money = 0

func _process(delta):
#	print("roundCount")
#	print(roundCount)
#	print("***********************************************************")	
#	print("enemyHealth")
#	print(enemyHealth)
#	print("***********************************************************")		
#	print("remainingEnemies")
#	print(remainingEnemies)
#	print("***********************************************************")	
#	print("enemySpeed")
#	print(enemySpeed)
#	print("***********************************************************")	
#	print("money")
#	print(money)
#	print("***********************************************************")		
	if remainingEnemies <= 0:
		roundCount += 1
		remainingEnemies =  10 * roundCount
		enemyHealth = 10 * roundCount
		if enemySpeed < maxEnemeySpeed:
			enemySpeed += 10
		
