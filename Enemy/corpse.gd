extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var random_rotation = randi() % 360
	rotation_degrees = random_rotation
	var timer = Timer.new()
	timer.connect("timeout",self,"_on_timeout")
	timer.wait_time = 0.2
	timer.one_shot = true
	add_child(timer)
	timer.start()
	pass # Replace with function body.

func _on_timeout():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
