extends AudioStreamPlayer2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var path_to_camera = NodePath()
onready var _camera = get_node(path_to_camera)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	position = _camera.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
