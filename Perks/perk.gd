extends Area2D

export var labelText = ""

onready var label = $Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = labelText



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
