extends Area2D

onready var timer = $Timer
onready var label = $Label
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()
	timer.connect("timeout", self, "_on_timeout")
	label.text = name

func _on_timeout():
	die()

func die():
	queue_free()
