extends RigidBody2D

const speed = 750
var explosion_active: bool = false
var explosion_radius: int = 400
onready var timer = $Timer
onready var animation = $AnimationPlayer

func _ready():
	timer.connect("timeout", self, "_on_timeout_end")

func explode():
	animation.play("explosion")
	animation.connect("animation_finished", self, "_on_animation_finished")
	explosion_active = true

func _process(_delta):
	if explosion_active:
		var targets = get_tree().get_nodes_in_group("Enemies")
		print(targets)
		for target in targets:
			var in_range = target.global_position.distance_to(global_position) < explosion_radius
			print(target.name)
			if "Enemy" in target.name and in_range:
				print("entra")
				target.takeDamage(1000)
			
func _on_timeout_end():
	explode()

func _on_animation_finished():
	queue_free()
