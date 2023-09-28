extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var path_to_player = NodePath()
onready var _player = get_node(path_to_player)

onready var roundLabel = $VBoxContainer/Round
onready var moneyAmountLabel = $VBoxContainer/Money
onready var zombiesRemainingLabel = $VBoxContainer/ZombiesRemaining
onready var enemyHealthLabel = $VBoxContainer/EnemyHealth
onready var enemySpeedLabel = $VBoxContainer/EnemySpeed
onready var maxSpawnTimerLabel = $VBoxContainer/MaxSpawnTimer
onready var playerHealthLabel = $VBoxContainer/PlayerHealth
onready var ammoLabel = $VBoxContainer/Ammo
onready var fpsLabel = $VBoxContainer/Fps
onready var zombiesSpawned = $VBoxContainer/ZombiesSpawned
onready var playerEnergyLabel = $VBoxContainer/PlayerEnergy
onready var playerMaxEnergyLabel = $VBoxContainer/PlayerMaxEnergy
onready var difficultyLabel = $VBoxContainer/Difficulty
onready var perksLabel = $VBoxContainer/Perks
onready var powerUpsLabel = $VBoxContainer/PowerUps
onready var globalPowerUpsLabel = $VBoxContainer/GlobalPowerUps
onready var magLabel = $VBoxContainer/Mag
onready var maxMagCapacityLabel = $VBoxContainer/MaxMagCapacity
onready var world = get_parent().get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	difficultyLabel.text = str("Difficulty ", Globals.difficulty)
	enemyHealthLabel.text = str("Enemies healtdh ", Globals.enemyHealth)
	enemySpeedLabel.text = str("Enemies speed ", Globals.enemySpeed)
	maxSpawnTimerLabel.text = str("Enemies spawn time ", Globals.max_spawn_timer)
	zombiesRemainingLabel.text = str("Enemies ", Globals.remainingEnemies)
	roundLabel.text = str("Round ",Globals.roundCount)
	if _player.money || _player.money == 0:
		moneyAmountLabel.text = str("$",_player.money)
	if _player.current_health:
		playerHealthLabel.text = str("Health ", _player.current_health)
	if _player.get_node("WeaponManager").current_weapon.ammo || _player.get_node("WeaponManager").current_weapon.ammo == 0:
		ammoLabel.text = str("Ammo ", _player.get_node("WeaponManager").current_weapon.ammo)
	var perks = ""
	for text in _player.perks:
		perks += str(" | ", text)
	perksLabel.text = str("perks", perks)		
	var power_ups = ""		
	for text in _player.power_ups:
		power_ups += str(" | ", text)
	powerUpsLabel.text = str("Power ups", power_ups)
	var global_power_ups = ""		
	for text in Globals.global_power_ups:
		global_power_ups += str(" | ", text)
	globalPowerUpsLabel.text = str("Global power ups", global_power_ups)
	fpsLabel.text = "FPS " + String(Engine.get_frames_per_second())
	zombiesSpawned.text = str("zombies spawned ", get_tree().get_nodes_in_group("Enemies").size())
	if _player.energy || _player.energy == 0:
		playerEnergyLabel.text = str("Player energy ",_player.energy)
	if _player.max_energy || _player.max_energy == 0:
		playerMaxEnergyLabel.text = str("Player max energy ",_player.max_energy)
	if _player.get_node("WeaponManager").current_weapon.mag || _player.get_node("WeaponManager").current_weapon.mag == 0:
		magLabel.text = str("Mag ", _player.get_node("WeaponManager").current_weapon.mag)
	if _player.get_node("WeaponManager").current_weapon.maxMagCapacity || _player.get_node("WeaponManager").current_weapon.maxMagCapacity == 0:
		maxMagCapacityLabel.text = str("Max mag capacity ", _player.get_node("WeaponManager").current_weapon.maxMagCapacity)
