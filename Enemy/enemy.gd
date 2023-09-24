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
	var moneyAmount = 10
	_on_money_earned("$"+str(moneyAmount))
	Globals.money += moneyAmount
	health -= damage
	if health <= 0:
		die()

func die():
	Globals.money += 50
	Globals.remainingEnemies -= 1
	queue_free()


func _on_money_earned(amount):
	var damage_label_scene = preload("res://World/Label.tscn")
	var damage_label_instance = damage_label_scene.instance()

	# Set the position for the label (you may want to adjust this based on your game's design).
	damage_label_instance.rect_min_size = Vector2(100, 30)
	damage_label_instance.set_global_position(global_position)

	# Add the damage label as a child to your game's root or a suitable parent node.
	get_parent().add_child(damage_label_instance)

	# Call the display_damage function on the label to show the damage amount.
	damage_label_instance.display_damage(amount)
