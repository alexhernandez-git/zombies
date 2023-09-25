extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var enemy_scene = preload("res://Enemy/enemy.tscn")
var current_zone
var previous_zone
onready var spawnPoints = [$Spawns/Spawn1, $Spawns/Spawn2, $Spawns/Spawn3]
 # Adjust this to control the spawn rate

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("round_passed", self, "_on_round_passed")
	randomize()  # Initialize the random number generato

func _physics_process(delta):
	Globals.spawn_timer -= delta
	if Globals.spawn_timer <= 0:
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

func rand_range_int(min_value, max_value):
	return randi() % (max_value - min_value + 1) + min_value
