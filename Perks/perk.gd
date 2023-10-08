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
	sprite.frame = Globals.perks_data[name].frame
	if "Health" in name:
		price = 2500
	if "Revive" in name:
		price = 1500
	if "Speed" in name:
		price = 2000
	if "Impulse" in name:
		price = 2500
	if "QuickFire" in name:
		price = 2000
	if "FastMag" in name:
		price = 3000
	if "Critical" in name:
		price = 4000
	if "MoreWeapons" in name:
		price = 4000
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
