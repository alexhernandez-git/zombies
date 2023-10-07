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
	var initPrice = price
	if "Health" in name:
		sprite.frame = 30
		price = 2500
	if "Revive" in name:
		sprite.frame = 29
		price = 1500
	if "Speed" in name:
		sprite.frame = 63
		price = 2000
	if "Impulse" in name:
		sprite.frame = 71
		price = 2500
	if "QuickFire" in name:
		sprite.frame = 28
		price = 2000
	if "FastMag" in name:
		sprite.frame = 36
		price = 3000
	if "Critical" in name:
		sprite.frame = 31
		price = 4000
	if "MoreWeapons" in name:
		sprite.frame = 22
		price = 4000
	if initPrice == 0:
		price = initPrice
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
