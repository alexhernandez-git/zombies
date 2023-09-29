extends CanvasModulate


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if player:
		var rColor = 255 - (player.current_health * 255 / 100)
		if rColor > 255:
			rColor = 255
		self.modulate = Color(rColor,0,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
