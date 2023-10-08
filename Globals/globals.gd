extends Node


# Perks = Health | Revive | Fast Fire | Reload protection | Fast reload | Slide 
# weapons = Gun | RifleOne | Subfusil | Sniper | Lanzacoetes  | Mini gun | Arrow
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

var game_paused = false

var power_ups = ["AtomicBomb", "MaxAmmo", "Vision", "InstantKill", "Invincibility", "UnlimitedFire", "MultipleWeapons", "DoublePoints", "Horde", "Supplies"]
var perks = ["Health", "Revive", "Speed", "Impulse", "QuickFire", "FastMag", "Critical", "MoreWeapons"]
var weapons = [ 
	"PistolOne", 
	"GrenadeOne", 
	"PistolTwo",
	"SubfusilOne", 
	"ShotgunOne", 
	"ShotgunTwo", 
	"RifleOne", 
	"RifleTwo", 
	"SniperOne", 
	"GrenadeTwo", 
	"MinigunOne", 
	"FlamethrowerOne", 
	"RocketLauncherOne", 
	"GrenadeLauncherOne" 
]

var round_0_weapons = [ "PistolOne"]

var round_5_weapons = [ "PistolOne","ShotgunOne"]

var round_10_weapons = [ "PistolOne","ShotgunOne", "RifleOne"]

var round_15_weapons = [ "PistolOne", "ShotgunOne", "RifleOne", "MinigunOne"]

var weapons_data = {
	"PistolOne": {
		"frame": 0
	},
	"GrenadeOne": {
		"frame": 1
	},
	"PistolTwo": {
		"frame":  8
	},
	"SubfusilOne": {
		"frame":  9
	},
	"RifleOne": {
		"frame":  24
	},
	"RifleTwo": {
		"frame":  25
	},	
	"SniperOne": {
		"frame":  32
	},
	"GrenadeTwo": {
		"frame": 33
	},	
	"ShotgunOne": {
		"frame":  16
	},
	"ShotgunTwo": {
		"frame":  17
	},
	"MinigunOne": {
		"frame":  40
	},
	"FlamethrowerOne": {
		"frame":  41
	},
	"RocketLauncherOne": {
		"frame":  48
	},
	"GrenadeLauncherOne": {
		"frame":  49
	},
}

var perks_data = {
	"Health": {
		"frame": 30
	},	
	"Revive": {
		"frame":  29
	},	
	"Speed": {
		"frame":  63
	},	
	"Impulse": {
		"frame":  71
	},
	"QuickFire": {
		"frame": 28
	},
	"FastMag": {
		"frame":  36
	},	
	"Critical": {
		"frame":  31
	},
	"MoreWeapons": {
		"frame":  22
	},
}

var global_power_ups = []

var roundCount = 1

var enemyAutoIncremental = 1

var enemyHealth = 50

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

var power_up_probability = 10

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

func _ready():
	var file = File.new()
	file.open("user_data.dat", File.READ)
	var player_data = file.get_var()
	print(player_data)
	if player_data:
		if "round_arrived" in player_data and player_data["round_arrived"] and player_data["round_arrived"] > 0:
			startingRound = player_data["round_arrived"] - 1
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
	remainingEnemies =  int(round(10 + (roundCount * 2)))
	#critical_probability = int(round(10 + (roundCount * 2)))
	if roundCount < 5:
		enemyHealth += 100
	else:
		enemyHealth = enemyHealth * 1.1

	if enemySpeed < maxEnemeySpeed:
		enemySpeed += difficulty_difference(5)
	print(str("enemyspeed", enemySpeed))
	max_spawn_timer -= 0.2
	if max_spawn_timer < 0.4:
		max_spawn_timer = 0.4

func _on_round_start():
	is_round_started = true

func get_clean_string(input_string):
	var reg = RegEx.new()
	var pattern = "@(.*?)@"
	reg.compile(pattern)
	var modifiedInput = reg.sub(input_string, "")
	return modifiedInput
