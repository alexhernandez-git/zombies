extends KinematicBody2D
class_name Enemy
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
onready var _sprite = $Sprite
onready var animation = $AnimationPlayer
onready var audio = $AudioStreamPlayer2D
onready var dead_timer = $DeadTimer
var health = Globals.enemyHealth
var id
const Enemies: String = "Enemies"
var disabled = false
var is_horde = false
var speed


func _init() -> void:
	# TODO: Fix this
	speed = Globals.enemySpeed
	if Globals.roundCount > 20:
		speed = Globals.enemySpeed
	add_to_group(Enemies)

func _ready() -> void: 
	id = Globals.enemyAutoIncremental
	Globals.enemyAutoIncremental += 1
	_animation.playback_speed = Globals.enemyHitSpeed
	_update_pathfinding()
	_timer.connect("timeout", self, "_update_pathfinding")
	Globals.connect("health_changed", self, "_on_health_changed")
	Globals.connect("enemy_damage", self, "_on_enemy_damage")
	Globals.connect("atomic_bomb", self, "_on_atomic_bomb")
	Globals.connect("horde_finished", self, "_on_horde_finished")
	
func _on_health_changed():
	pass
	
func _physics_process(delta: float) -> void:
	if _agent.is_navigation_finished():
		return
	
	var previous_position = position
	
	var direction = global_position.direction_to(_agent.get_next_location())
	
	var enemySpeed = speed
	if is_horde:
		enemySpeed = Globals.maxEnemeySpeed
	var desired_velocity = direction * enemySpeed
	var steering = (desired_velocity - velocity) * delta * 4.0
	velocity += steering
	
	velocity = move_and_slide(velocity)

	if velocity.x > 0: 
		animation.play("walk")
	elif velocity.x < 0:
		animation.play("walk")
	else:
		animation.play("RESET")
		
	
	if position.x > previous_position.x:
		# Enemy is moving to the right
		_sprite.flip_h = false
		
	elif position.x < previous_position.x:
		# Enemy is moving to the left
		_sprite.flip_h = true
	else:
		# Enemy is not moving horizontally (or moving at the same position)
		pass

func _update_pathfinding() -> void:
	if _player:
		_agent.set_target_location(_player.global_position)

func _on_DetectionZone_body_entered(body):
	if body.name == "Player":
		_player = body
	_update_pathfinding()

func takeDamage(damage: int, critical = false):
	if disabled:
		return
	audio.play()
	Globals.emit_signal("enemy_damage", global_position, critical)
	if not is_horde:
		var money = Globals.enemyHitMoney
		if "DoublePoints" in Globals.global_power_ups:
			money *= 2
		Globals.emit_signal("money_earned", money)
	health -= damage * 2
	if "InstantKill" in Globals.global_power_ups:
		health = 0
	if health <= 0:
		die(critical)

func _on_timeout_show_hit_mark():
	_hit_marker_sprite.visible = false

func die(critical = false):
	_sprite.visible = false
	name = ""
	disabled = true

	var money = Globals.enemyKillMoney	
	if critical:
		money = Globals.enemyCriticalKillMoney
	if "DoublePoints" in Globals.global_power_ups:
		money *= 2
	if is_horde: 
		if "DoublePoints" in Globals.global_power_ups:
			Globals.emit_signal("money_earned", 20)
		else:
			Globals.emit_signal("money_earned", 10)
			
	else:
		Globals.emit_signal("money_earned", money)
	Globals.emit_signal("enemy_died", self)
	dead_timer.start()
	dead_timer.connect("timeout", self, "_on_dead_timeout")

func _on_atomic_bomb():
	Globals.emit_signal("enemy_died", self)
	queue_free()

func _on_dead_timeout():
	queue_free()
	
func _on_horde_finished():
	if is_horde:
		queue_free()

func _on_PlayerDetector_area_entered(area):
	if "hurtBox" in area.name:
		_animation.play("scale_hit_collision")


func _on_PlayerDetector_area_exited(area):
	if "hurtBox" in area.name:
		_animation.play("RESET")
