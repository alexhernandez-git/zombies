extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var damage = 20

var player: Player


var has_hitted = false

var collateral = true

onready var particles = $Particles2D

var is_fire = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fire(pos):
	global_position = pos
	z_index = 10
	particles.emitting = true
	is_fire = true
	$AnimationPlayer.play("fire")

func stop():
	is_fire = false
	particles.emitting = false
	$AnimationPlayer.play("RESET")

func quick_fire():
	$AnimationPlayer.playback_speed = 2
	

func reset_quick_fire():
	$AnimationPlayer.playback_speed = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Fire_body_entered(body):
	if not is_fire:
		return
	if body.has_method("takeDamage") and "Enemy" in body.name and  body.name != "Player":
		var critical = false
		var random_number = randi() % Globals.critical_probability + 1
		var probability = 1
		var body_damage = damage
		if player:
			var maxHitCritical = 10
			var damageMultiplier = 2
			if "Critical" in player.perks:
				maxHitCritical = 25
				damageMultiplier = 3
			if player.hit_feed > maxHitCritical:
				probability *= maxHitCritical
			else:
				probability *= player.hit_feed
			if random_number <= probability:
				body_damage *= damageMultiplier
				critical = true
				player.hit_feed = 0
			if "QuickFire" in player.power_ups:
				body_damage *= 2
		body.takeDamage(body_damage, critical)
		has_hitted = true
		if player:
			player.hit_feed += 1
	if not has_hitted and player:
		player.hit_feed = 0
	if "FirstFloorWallsCollider" in body.name:
		queue_free()
	if not collateral:
		queue_free()
