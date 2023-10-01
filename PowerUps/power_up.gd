extends Area2D

onready var timer = $Timer
onready var sprite = $Sprite
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()
	timer.connect("timeout", self, "_on_timeout")
	if "AtomicBomb" in name:
		sprite.frame = 4
	if "MaxAmmo" in name:
		sprite.frame = 5
	if "Vision" in name:
		sprite.frame = 7
	if "InstantKill" in name:
		sprite.frame = 6
	if "Invincibility" in name:
		sprite.frame = 13
	if "UnlimitedFire" in name:
		sprite.frame = 21
	if "MultipleWeapons" in name:
		sprite.frame = 47
	if "DoublePoints" in name:
		sprite.frame = 14
	if "Horde" in name:
		sprite.frame = 37

func _on_timeout():
	die()

func die():
	queue_free()
