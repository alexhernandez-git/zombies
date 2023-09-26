extends KinematicBody2D

var velocity = Vector2.ZERO
export var path_to_player = NodePath()
onready var _agent: NavigationAgent2D = $NavigationAgent2D
onready var _player = get_node(path_to_player)
onready var _timer: Timer = $Timer
onready var _label: Label = $Label
onready var _label_timer: Timer = $LabelTimer
onready var _hitBoxCollision = $hitBox/CollisionShape2D
onready var _animation = $HitAnimation
onready var _hit_marker_sprite = $HitMarkerSprite
var health = Globals.enemyHealth

func _ready() -> void: 
	_animation.playback_speed = Globals.enemyHitSpeed
	_update_pathfinding()
	_timer.connect("timeout", self, "_update_pathfinding")
	Globals.connect("health_changed", self, "_on_health_changed")
	Globals.connect("atomic_bomb", self, "_on_atomic_bomb")
	
func _on_health_changed():
	print("entra")
	
func _physics_process(delta: float) -> void:
	if _agent.is_navigation_finished():
		return
	
	var direction = global_position.direction_to(_agent.get_next_location())
	
	var desired_velocity = direction * Globals.enemySpeed
	var steering = (desired_velocity - velocity) * delta * 4.0
	velocity += steering
	
	velocity = move_and_slide(velocity)

func _update_pathfinding() -> void:
	if _player:
		_agent.set_target_location(_player.global_position)

func _on_DetectionZone_body_entered(body):
	if body.name == "Player":
		_player = body
	_update_pathfinding()

func takeDamage(damage: int, mele = false):
	Globals.emit_signal("enemy_damage", global_position)
	Globals.emit_signal("money_earned", Globals.enemyHitMoney)
	health -= damage
	if Globals.instantKill:
		health = 0
	if health <= 0:
		die(mele)

func _on_timeout_show_hit_mark():
	_hit_marker_sprite.visible = false

func die(mele = false):
	var money = Globals.enemyKillMoney
	if mele:
		money = Globals.enemyKillMoneyMele
	Globals.emit_signal("money_earned", money)
	Globals.emit_signal("enemy_died", global_position)
	Globals.remainingEnemies -= 1
	queue_free()

func _on_atomic_bomb():
	Globals.emit_signal("enemy_died", global_position)
	Globals.remainingEnemies -= 1
	queue_free()


func _on_PlayerDetector_area_entered(area):
	if ("hurtBox" in area.name):
		_animation.play("scale_hit_collision")


func _on_PlayerDetector_area_exited(area):
	if ("hurtBox" in area.name):
		_animation.play("RESET")
