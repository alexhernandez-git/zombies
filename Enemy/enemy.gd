extends KinematicBody2D

var _velocity = Vector2.ZERO

export var path_to_player = NodePath()
onready var _agent: NavigationAgent2D = $NavigationAgent2D
onready var _player = get_node(path_to_player)
onready var _timer: Timer = $Timer

func _ready() -> void: 
	_update_pathfinding()
	_timer.connect("timeout", self, "_update_pathfinding")

func _physics_process(delta: float) -> void:
	if _agent.is_navigation_finished():
		return
	
	var direction = global_position.direction_to(_agent.get_next_location())
	
	var desired_velocity = direction * 100.0
	var steering = (desired_velocity - _velocity) * delta * 4.0
	_velocity += steering
	
	_velocity = move_and_slide(_velocity)

func _update_pathfinding() -> void:
	if _player:
		_agent.set_target_location(_player.global_position)

func _on_DetectionZone_body_entered(body):
	if body.name == "Player":
		_player = body
	_update_pathfinding()
	pass # Replace with function body.
	
func die():
	queue_free()
