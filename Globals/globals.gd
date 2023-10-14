extends Node


# Perks = Health | Revive | Fast Fire | Reload protection | Fast reload | Slide 
# weapons = Gun | Rifle | Subfusil | Sniper | Lanzacoetes  | Mini gun | Arrow
# Granades = Granade | Fire |
# Cuerpo a cuerpo = Knife | Hacha | Espada | Bate
# Especials = Hammer | Agujero negro | Desintegrador | Teleport gun | Lanzallamas | Tomahawk
# Slide boots
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# TODO delay time when a round is done

# Todo do maps and a arena that you can use everything that you get from the maps

# Do more than one try to upgrade the weapon

# New powerup that add a free perk

# Crear una clase donde te salga mas de unas y menos de otras ventajas

# Si se hace multijugador mover el timeout del global powerups fuera del jugador

# Los enemigos te dropearan nuevas armas que podras usar en las siguentes partidas

# The normal guns you can get them with random supplies but the guns improvements you can get it with game challenges

# Once you get a gun you are able to improve it to dure 5 rounds more

# Each 5 rounds bring a random supply that contains one of the previous range of weapons and perks

# New enemy, shot a rafaga de izquierda a derecha y de derecha a izquierda

# New enemy shot player

# New enemy throw grenades

# Weapon: saws alrededor del jugador

# Solider aliade

var game_paused = false

var power_ups = ["AtomicBomb", "MaxAmmo", "Vision", "InstantKill", "Invincibility", "UnlimitedFire", "MultipleWeapons", "DoublePoints", "Horde", "Supplies"]
var perks = ["Health", "Revive", "Speed", "Impulse", "QuickFire", "FastMag", "Critical", "MoreWeapons"]
var weapons = [ 
	"Pistol", 
	"Grenade", 
	"PistolTwo",
	"Subfusil", 
	"Shotgun", 
	"ShotgunTwo", 
#	"GrenadeTwo", 
	"Rifle", 
	"RifleTwo", 
	"Sniper", 
#	"GrenadeThree", 
	"Minigun", 
	"Flamethrower", 
	"RocketLauncher", 
	"GrenadeLauncher" 
]

var weapons_data = {
	"Pistol": {
		"frame": 0,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"Grenade": {
		"frame": 1,
		"price": 500,
		"maxAmmo": 3 ,
		"isTrowable": true
	},
	"PistolTwo": {
		"frame":  8,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"Subfusil": {
		"frame":  9,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"Shotgun": {
		"frame":  16,
		"price": 600,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"ShotgunTwo": {
		"frame":  17,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"GrenadeTwo": {
		"frame": 18,
		"price": 500,
		"isTrowable": true
	},	
	"Rifle": {
		"frame":  24,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"RifleTwo": {
		"frame":  25,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},	
	"Sniper": {
		"frame":  32,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"GrenadeThree": {
		"frame": 33,
		"price": 500,
		"isTrowable": true
	},	
	"Minigun": {
		"frame":  40,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"Flamethrower": {
		"frame":  41,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false
	},
	"RocketLauncher": {
		"frame":  48,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false,
		"proyectileFrame": 58
	},
	"GrenadeLauncher": {
		"frame":  49,
		"price": 500,
		"ammoPrice": 250,
		"isTrowable": false,
		"proyectileFrame": 1
	}
}

var perks_data = {
	"MoreWeapons": {
		"frame":  31
	},
	"Critical": {
		"frame":  30
	},
	"FastMag": {
		"frame":  23
	},	
	"QuickFire": {
		"frame": 22
	},
	"Impulse": {
		"frame":  6
	},
	"Speed": {
		"frame":  7
	},	
	"Revive": {
		"frame":  14
	},	
	"Health": {
		"frame": 15
	},	
}

var global_power_ups = []

var roundCount = 1

var enemyAutoIncremental = 1

var enemyHealth = 25

var maxEnemyHealth = 1000

var remainingEnemies = 5

var enemySpeed = 10

var spawn_timer = 0

export var maxEnemeySpeed = 100

export var max_spawn_timer = 3.0

export var startingRound = 0

var difficulty =  10

var enemyHitSpeed = 1

var enemyHitMoney = 10

var enemyKillMoney = 50

var enemyCriticalKillMoney = 100

var critical_probability = 100

var enemyKillMoneyMele = 100

var instantKill = false

var power_up_wait_time = 15

var power_up_probability = 5

var atomic_bomb_money = 400

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
signal unpaused
signal open_inventory
signal close_inventory
signal trow_object
signal horde_finished
signal call_supplies
signal drop_supplies
signal unlocked_gun
signal unlocked_perk
signal shoot

func _ready():
	var file = File.new()
	file.open("user_data.dat", File.READ)
	var player_data = file.get_var()
	if player_data:
		if "round_arrived" in player_data and player_data["round_arrived"] and player_data["round_arrived"] > 0:
			#startingRound = player_data["round_arrived"] - 1
			startingRound = 0
	file.close()
	for i in range(startingRound):
		_on_round_finished()
		_on_round_start()

func difficulty_difference(amount: float) -> float:
	return amount + (difficulty * amount / 10)

func difficulty_difference_substract(amount: float) -> float:
	return amount - (difficulty * amount / 10)

func _on_round_finished():
	is_round_started = false
	roundCount += 1
	
	if roundCount > 5:
		power_up_probability = 10
	
	if roundCount > 9:
		remainingEnemies = int(round(10 + (roundCount * 5)))
	else:
		remainingEnemies =  int(round(10 + (roundCount * 2)))
	#critical_probability = int(round(10 + (roundCount * 2)))
	if roundCount < 5:
		enemyHealth += 50
	else:
		enemyHealth = enemyHealth + 25
	
	if enemyHealth > maxEnemyHealth:
		enemyHealth = maxEnemyHealth

	enemySpeed += 10
	if enemySpeed > maxEnemeySpeed:
		enemySpeed = maxEnemeySpeed
	max_spawn_timer -= 0.1
	if max_spawn_timer < 1:
		max_spawn_timer = 1

func _on_round_start():
	is_round_started = true

func get_clean_string(input_string):
	var reg = RegEx.new()
	var pattern = "@(.*?)@"
	reg.compile(pattern)
	var modifiedInput = reg.sub(input_string, "")
	return modifiedInput
