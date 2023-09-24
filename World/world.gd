extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player
var tilemaps = []
var currentTilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	player = $Player
	tilemaps = [$Map/FirstFloor,$Map/SeccondFloor]
	pass # Replace with function body.

func _process(delta):
	print(currentTilemap)
	if currentTilemap:
		for tilemap in tilemaps:
			if tilemap == currentTilemap:
				tilemap.visible = true
			else:
				tilemap.visible = false

	if player != null and tilemaps.size() > 0:
		var player_position = player.global_position
		print(player_position)
		for tilemap in tilemaps:
			if tilemap != null:
				var tilemap_position = tilemap.world_to_map(player_position)
				if currentTilemap and currentTilemap.get_cell(tilemap_position.x, tilemap_position.y) != -1:
					currentTilemap = currentTilemap
					break
				if tilemap.get_cell(tilemap_position.x, tilemap_position.y) != -1:
					currentTilemap = tilemap

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
