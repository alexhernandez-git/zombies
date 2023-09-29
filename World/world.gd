extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var enemy_scene = preload("res://Enemy/enemy.tscn")
var power_up_scene = preload("res://PowerUps/power_up.tscn")
var _blood_sprite = preload("res://Enemy/blood.tscn")
var _corpse_sprite = preload("res://Enemy/corpse.tscn")
var current_zone
var previous_zone
onready var afterRoundTimer = $AfterRound
onready var spawnPoints = [$Spawns/Spawn1, $Spawns/Spawn2, $Spawns/Spawn3, $Spawns/Spawn4, $Spawns/Spawn5]
var spawned_enemies = 0
var last_enemy_died
 # Adjust this to control the spawn rate

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("round_finished", self, "_on_round_finished")
	Globals.connect("enemy_died", self, "_on_enemy_died")
	Globals.connect("enemy_damage", self, "_on_enemy_damage")
	randomize()  # Initialize the random number generato

func _physics_process(delta):
	if get_tree().get_nodes_in_group("Enemies").size() == 0 and Globals.remainingEnemies == 0 and Globals.is_round_started:
		Globals._on_round_finished()
		Globals.emit_signal("round_finished")

	
	Globals.spawn_timer -= delta
	
	if Globals.is_round_started == true and Globals.spawn_timer <= 0 and Globals.remainingEnemies > get_tree().get_nodes_in_group("Enemies").size() and get_tree().get_nodes_in_group("Enemies").size() < 20 and not Globals.atomic_bomb:
		spawn_enemy()
		Globals.spawn_timer = rand_range(0.1, Globals.max_spawn_timer)  # Adjust the range for random spawn intervals

func _on_round_finished():
	afterRoundTimer.start()
	afterRoundTimer.connect("timeout", self, "_on_round_start")

func _on_round_start():
	Globals.emit_signal("round_passed")
	Globals._on_round_start()
	

func spawn_enemy():
	var enemy_instance = enemy_scene.instance()
	var randomIndex = randi() % spawnPoints.size()
	var randomSpawnPoint = spawnPoints[randomIndex]
	if randomSpawnPoint:
		enemy_instance.position = randomSpawnPoint.global_position
		enemy_instance.z_index = 1
		add_child(enemy_instance)
		spawned_enemies += 1

func rand_range_int(min_value, max_value):
	return randi() % (max_value - min_value + 1) + min_value

func generateRandomPosition(position):
	var random_angle = rand_range(0, 2 * PI)  # Random angle in radians
	var random_radius = rand_range(0, 10)     # Random radius within 1 meter
	var x_offset = cos(random_angle) * random_radius
	var y_offset = sin(random_angle) * random_radius
	var random_position = position + Vector2(x_offset, y_offset)
	
	return random_position

func _on_enemy_damage(position):
	var blood_instance = _blood_sprite.instance()
	blood_instance.global_position =  generateRandomPosition(position)
	add_child(blood_instance)

func _on_enemy_died(enemy: Enemy):
	if last_enemy_died == enemy.name:
		return
	last_enemy_died = enemy.name
	Globals.remainingEnemies -= 1
	var corpse_instance = _corpse_sprite.instance()
	corpse_instance.global_position = enemy.global_position
	add_child(corpse_instance)
# Generate a random number between 1 and 10
	var random_number = randi() % Globals.power_up_probability + 1
	
	# Calculate the probability of getting a true result (e.g., 30%)
	var probability = 1  # Adjust this value to set your desired probability
	
	# Check if the random number falls within the desired probability range
	if random_number <= probability:
		var randomIndex = randi() % Globals.power_ups.size() + 1
		var power_up_instance = power_up_scene.instance()
		power_up_instance.name = Globals.power_ups[randomIndex - 1]
		power_up_instance.z_index = 1
		power_up_instance.global_position = position
		add_child(power_up_instance)
