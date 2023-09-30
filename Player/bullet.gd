extends Area2D

export var speed: int = 10

var damage = 20

var direction = Vector2.ZERO

var player: Player

var has_hitted = false

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
		var critical = false
		var random_number = randi() % Globals.critical_probability + 1
		var probability = 1
		if player:
			if "Critical" in player.perks:
				probability *= player.hit_feed
			if random_number <= probability:
				damage *= 10
				critical = true
		body.takeDamage(damage, critical)
		has_hitted = true
		if player:
			player.hit_feed += 1
		return
	if body.name != "Player" and not "Enemy" in body.name:
		queue_free()
	if not has_hitted and player:
		player.hit_feed = 0
