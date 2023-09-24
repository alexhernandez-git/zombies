extends Label

func _ready():
	hide()

func display_damage(damage_amount):
	text = str(damage_amount)
	show()
	$Timer.start()

func _on_Timer_timeout():
	hide()
