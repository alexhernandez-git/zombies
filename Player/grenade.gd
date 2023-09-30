extends RigidBody2D

const speed = 10
var explosion_active: bool = false
var explosion_radius: int = 100
onready var animation = $AnimationPlayer
onready var timer = $Timer

func _ready():
	visible = true
	animation.play("explosion")
	animation.connect("animation_finished", self, "_on_animation_finished")
	timer.connect("timeout", self, "_on_timeout")

func explode():
	explosion_active = true

func _process(_delta):
	if explosion_active:
		linear_velocity = Vector2(0, 0)
		var targets = get_tree().get_nodes_in_group("Enemies")
		print(targets)
		var uniqueItems = {}
		for item in targets:
			if not uniqueItems.has(item):
				uniqueItems[item] = true
		for item in uniqueItems.keys():
			targets.append(item)
		for target in targets:
			var in_range = target.global_position.distance_to(global_position) < explosion_radius
			if "Enemy" in target.name and in_range:
				target.takeDamage(100)
	explosion_active = false
			
func _on_animation_finished(animation):
	queue_free()

func _on_timeout():
	explode()
