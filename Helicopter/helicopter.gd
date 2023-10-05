extends KinematicBody2D

var speed = 100
var acceleration = 500
var max_speed = 200
var rotation_speed = 2
var position_target: Vector2
var hasDropped = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	# Calculate the direction to the player
	var target_direction = (position_target - global_position).normalized()

	# Calculate velocity based on acceleration
	var velocity = move_and_slide(target_direction * speed, Vector2.ZERO)

	# Limit the helicopter's speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
		move_and_slide(velocity)
		
	if global_position.distance_to(position_target) < 10.0 and not hasDropped:  # Adjust the threshold as needed
		# Helicopter has arrived at the target position
		hasDropped = true
		Globals.emit_signal("drop_supplies", global_position)
		queue_free()
