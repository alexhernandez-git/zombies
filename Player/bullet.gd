extends Area2D

export var speed: int = 10

var damage = 20

var direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		
		global_position += velocity

func set_direction(direction: Vector2):
	self.direction = direction

func set_damage(damage_amount):
	damage = damage_amount

func _on_Bullet_body_entered(body):
	if body.has_method("takeDamage") and  body.name != "Player":
		body.takeDamage(damage)
	if body.name != "Player" and not "Enemy" in body.name:
		queue_free()
