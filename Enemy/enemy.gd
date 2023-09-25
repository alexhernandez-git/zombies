extends KinematicBody2D

var _velocity = Vector2.ZERO

export var path_to_player = NodePath()
onready var _agent: NavigationAgent2D = $NavigationAgent2D
onready var _player = get_node(path_to_player)
onready var _timer: Timer = $Timer
onready var _label: Label = $Label
onready var _label_timer: Timer = $LabelTimer
var health = Globals.enemyHealth


func _ready() -> void: 
	_update_pathfinding()
	_timer.connect("timeout", self, "_update_pathfinding")
	Globals.connect("health_changed", self, "_on_health_changed")
	Globals.connect("atomic_bomb_detonated", self, "_on_atomic_bomb_detonated")
	
func _on_health_changed():
	print("entra")
	
func _physics_process(delta: float) -> void:
	if _agent.is_navigation_finished():
		return
	
	var direction = global_position.direction_to(_agent.get_next_location())
	
	var desired_velocity = direction * Globals.enemySpeed
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

func takeDamage(damage: int):
	Globals.emit_signal("money_earned", 10)
	health -= damage
	if health <= 0:
		die()

func die():
	Globals.emit_signal("money_earned", 50)
	Globals.emit_signal("enemy_died", global_position)
	Globals.remainingEnemies -= 1
	queue_free()

func _on_atomic_bomb_detonated():
	Globals.emit_signal("enemy_died")
	Globals.remainingEnemies -= 1
	queue_free()
