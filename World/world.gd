extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var enemy_scene = preload("res://Enemy/enemy.tscn")
var player
var zones = []
var current_zone
onready var spawnPoint = $SpawnPoint
var spawn_timer = 2.0  # Adjust this to control the spawn rate

# Called when the node enters the scene tree for the first time.
func _ready():
	player = $Player
	zones = [
		{
			"tileMaps": [
				$FirstFloorGround, 
				$FirstFloorWallsCollider, 
				$FirstFloorWalls
			],
			"spawnPoints": [
				$SpawnPoints/SpawnPoint
			]
		}, 
		{
			"tileMaps": [
				$SeccondFloorGround,
				$SeccondFloorWallsColider
			],
			"spawnPoints": [
				$SpawnPoints/SpawnPoint2,
			]
		}
	]
	randomize()  # Initialize the random number generator

func _process(delta):
	if current_zone:

		for zone in zones:
			if current_zone == zone:
				for tilemap in zone["tileMaps"]:
					tilemap.visible = true
					
				var index = zones.find(zone,0) 
				print(index)
				player.set_collision_layer_bit(index, true)
				player.set_collision_mask_bit(index, true)
			else:
				for tilemap in zone["tileMaps"]:
					tilemap.visible = false
				var index = zones.find(zone,0) 
				print(index)
				player.set_collision_layer_bit(index, false)
				player.set_collision_mask_bit(index, false)


	if player != null and zones.size() > 0:
		var player_position = player.global_position
		var isCurrent = false
		for zone in zones:
			if isCurrent: 
				break
			if zone != null:
				for tilemap in zone["tileMaps"]:
					if isCurrent: 
						break
					if current_zone:
						for current_tilemap in current_zone["tileMaps"]:
							var tilemap_position = current_tilemap.world_to_map(player_position)
							if current_tilemap.get_cell(tilemap_position.x, tilemap_position.y) != -1:
								isCurrent = true;
								print("entra1")
								break
					if not isCurrent:
						var tilemap_position = tilemap.world_to_map(player_position)
						if tilemap.get_cell(tilemap_position.x, tilemap_position.y) != -1:
							print("entra")
							current_zone = zone
						else:
							print("no entra")
			
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = rand_range(1.0, 3.0)  # Adjust the range for random spawn intervals

func spawn_enemy():
	var enemy_instance = enemy_scene.instance()
	enemy_instance.position = current_zone["spawnPoints"][0].global_position
	enemy_instance.z_index = 1
	add_child(enemy_instance)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
