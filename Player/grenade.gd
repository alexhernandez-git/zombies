extends RigidBody2D

const speed = 10
var explosion_active: bool = false
var explosion_radius: int = 100
onready var timer = $Timer
onready var collisionShape = $CollisionShape2D
onready var sprite = $Sprite
onready var light = $Light2D
onready var particles = $Particles2D
onready var particlesTimer = $ParticlesTimer
onready var animationPlayer = $AnimationPlayer
onready var audio = $AudioStreamPlayer2D
var damage_active = false
var damage = 500
var explode_on_touch = false

func _ready():
	timer.connect("timeout", self, "_on_timeout")

func explode():
	explosion_active = true
	particles.emitting = true	
	animationPlayer.play("explosion")
	damage_active = true
	sprite.visible = false
	light.visible = true
	particlesTimer.start()	
	audio.play()

func _process(_delta):
	if explosion_active and damage_active:
		linear_velocity = Vector2(0, 0)
		var targets = get_tree().get_nodes_in_group("Enemies")
		var uniqueItems = {}
		for item in targets:
			if not uniqueItems.has(item):
				uniqueItems[item] = true
		for item in uniqueItems.keys():
			targets.append(item)
		for target in targets:
			var in_range = target.global_position.distance_to(global_position) < explosion_radius
			if "Enemy" in target.name and in_range:
				target.takeDamage(damage)
		damage_active = false
		particlesTimer.connect("timeout", self, "_on_particles_timeout")

func _on_timeout():
	explode()

func _on_particles_timeout():
	queue_free()

func _on_Area2D_area_entered(area):
	if not explode_on_touch:
		return
	if "NearDetector" in area.name:
		timer.stop()
		explode()

