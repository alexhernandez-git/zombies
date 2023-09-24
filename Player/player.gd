extends KinematicBody2D

export (PackedScene) var Bullet

var SPEED = 120

var DISTANCE_IN_FRONT = 15

onready var light = $Light2D
onready var maskedLight = $Light2D3

onready var shootPosition = $WeaponStartPositions/ShootPosition

onready var canShootTimer = $Timer

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if Input.is_action_pressed("shoot"):
		shoot()
	
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var move_direction = input_vector.normalized()
	move_and_slide(SPEED * move_direction)
	
	light.rotation = get_angle_to(get_global_mouse_position())
	maskedLight.rotation = get_angle_to(get_global_mouse_position())
	
	var player_direction = (get_global_mouse_position() - position).normalized()
	var target_position = global_position + player_direction * DISTANCE_IN_FRONT
	shootPosition.global_position = target_position

func shoot():
	if canShootTimer.is_stopped():
		canShootTimer.start()
		var bullet_instance = Bullet.instance()
		add_child(bullet_instance)
		bullet_instance.global_position = shootPosition.global_position
		var target = get_global_mouse_position()
		var direction_to_mouse = bullet_instance.global_position.direction_to(target).normalized()
		bullet_instance.set_direction(direction_to_mouse)

func _on_hurtBox_area_entered(area):
	print("area")
	pass # Replace with function body.
