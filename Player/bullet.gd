extends Area2D

export var speed: int = 10

var direction = Vector2.ZERO
onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")

func _physics_process(delta):
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity

func set_direction(direction: Vector2):
	self.direction = direction

func _on_timer_timeout():
	queue_free()  # Destroy the bullet when the timer expires


func _on_Bullet_body_entered(body):
	print(body.name)
	if body.has_method("die"):
		body.die()
	if body.name != "Player" and not  "Enemy" in body.name:
		queue_free()
