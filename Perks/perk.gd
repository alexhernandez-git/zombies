extends Area2D

export var labelText = ""

onready var label = $Label
onready var sprite = $Sprite
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if "Health" in name:
		sprite.frame = 30
	if "Revive" in name:
		sprite.frame = 29
	if "Speed" in name:
		sprite.frame = 63
	if "Impulse" in name:
		sprite.frame = 71
	if "QuickFire" in name:
		sprite.frame = 28
	if "FastMag" in name:
		sprite.frame = 36
	if "Critical" in name:
		sprite.frame = 31
	if "MoreWeapons" in name:
		sprite.frame = 22


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
