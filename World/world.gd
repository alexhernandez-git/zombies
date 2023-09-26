extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var enemy_scene = preload("res://Enemy/enemy.tscn")
var power_up_scene = preload("res://PowerUps/power_up.tscn")
var current_zone
var previous_zone
onready var spawnPoints = [$Spawns/Spawn1, $Spawns/Spawn2, $Spawns/Spawn3, $Spawns/Spawn4, $Spawns/Spawn5]
var spawned_enemies = 0
 # Adjust this to control the spawn rate

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("round_passed", self, "_on_round_passed")
	Globals.connect("enemy_died", self, "_on_enemy_died")
	randomize()  # Initialize the random number generato

func _physics_process(delta):
	Globals.spawn_timer -= delta
	
	if Globals.spawn_timer <= 0 and Globals.remainingEnemies > spawned_enemies and spawned_enemies < 20:
		# TODO: spawn 5 enem
		spawn_enemy()
		Globals.spawn_timer = rand_range(0.1, Globals.max_spawn_timer)  # Adjust the range for random spawn intervals
	
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

func _on_enemy_died(position):
# Generate a random number between 1 and 10
	var random_number = randi() % 10 + 1
	#var random_number = randi() %  + 1
	
	# Calculate the probability of getting a true result (e.g., 30%)
	var probability = 1  # Adjust this value to set your desired probability
	
	# Check if the random number falls within the desired probability range
	if random_number <= probability :
		var randomIndex = randi() % Globals.power_ups.size() + 1
		var power_up_instance = power_up_scene.instance()
		power_up_instance.name = Globals.power_ups[randomIndex - 1]
		power_up_instance.z_index = 1
		power_up_instance.global_position = position
		add_child(power_up_instance)
	spawned_enemies -= 1
