extends RigidBody2D

const speed = 10
var explosion_active: bool = false
var explosion_radius: int = 400
onready var animation = $AnimationPlayer

func _ready():
	visible = true
	animation.play("explosion")
	animation.connect("animation_finished", self, "_on_animation_finished")

func explode():
	explosion_active = true

func _process(_delta):
	if explosion_active:
		var targets = get_tree().get_nodes_in_group("Enemies")
		for target in targets:
			var in_range = target.global_position.distance_to(global_position) < explosion_radius
			print(target.name)
			if "Enemy" in target.name and in_range:
				target.takeDamage(1000)
		queue_free()
			
func _on_animation_finished(animation):
	explode()	
