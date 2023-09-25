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
onready var perksLabel = $VBoxContainer/Perks

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	enemyHealthLabel.text = str("Enemies healtdh ", Globals.enemyHealth)
	enemySpeedLabel.text = str("Enemies speed ", Globals.enemySpeed)
	maxSpawnTimerLabel.text = str("Enemies spawn time ", Globals.max_spawn_timer)
	zombiesRemainingLabel.text = str("Enemies ", Globals.remainingEnemies)
	roundLabel.text = str("Round ",Globals.roundCount)
	if _player.money || _player.money == 0:
		moneyAmountLabel.text = str("$",_player.money)
	if _player.current_health:
		playerHealthLabel.text = str("Health ", _player.current_health)
	if _player.ammo || _player.ammo == 0:
		ammoLabel.text = str("Ammo ", _player.ammo)
	var perks = ""
	for text in _player.perks:
		perks += str(" | ", text)
	perksLabel.text = str("perks", perks)