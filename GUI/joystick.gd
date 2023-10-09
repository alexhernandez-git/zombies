extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if $TouchScreenButton.is_pressed():
			print(event.position)
