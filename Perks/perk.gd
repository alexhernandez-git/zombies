extends Area2D

export var labelText = ""
export var price: float
onready var label = $Label
onready var sprite = $Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if "Health" in name:
		sprite.frame = 30
		if not price:
			price = 2500
	if "Revive" in name:
		sprite.frame = 29
		if not price:
			price = 1500
	if "Speed" in name:
		sprite.frame = 63
	if not price:
		price = 2000
	if "Impulse" in name:
		sprite.frame = 71
		if not price:
			price = 2500
	if "QuickFire" in name:
		sprite.frame = 28
		if not price:
			price = 2000
	if "FastMag" in name:
		sprite.frame = 36
		if not price:
			price = 3000
	if "Critical" in name:
		sprite.frame = 31
		if not price:
			price = 4000
	if "MoreWeapons" in name:
		sprite.frame = 22
		if not price:
			price = 4000
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
