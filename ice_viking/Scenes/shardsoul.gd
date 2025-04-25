extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $Hitbox
@onready var direction_timer = $DirectionTimer
@onready var health_bar: ProgressBar = $Control/HealthBar

const SPEED = 40
const GRAVITY = 900
const JUMP_FORCE = -300
const MAX_JUMP_TIME = 0.5
@export var max_hp := 10
var hp: int = max_hp
var damage_amount = 1
var is_dealing_damage = false
var is_chasing = false
var dir = Vector2.RIGHT
var player = null
var damage_cooldown = 1.0
var attack_distance = 65
var is_dead: bool = false
var is_hurt: bool = false
var is_jumping = false
var jump_timer = 0.0

func _ready():
	if not detection_area:
		push_error("Area2D nije pronađena! Provjerite strukturu čvorova.")
		return

	health_bar.max_value = max_hp
	health_bar.value = hp
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

	if not direction_timer.timeout.is_connected(_on_direction_timer_timeout):
		direction_timer.timeout.connect(_on_direction_timer_timeout)

	animated_sprite_2d.play("idle")

func _physics_process(delta):
	if is_dead or is_hurt:
		return

	# Gravitacija
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		is_jumping = true
	else:
		is_jumping = false
		jump_timer = 0.0

	# Lov na igrača
	if is_chasing and player and is_instance_valid(player):
		var direction = global_position.direction_to(player.global_position)
		velocity.x = direction.x * SPEED
		animated_sprite_2d.flip_h = direction.x < 0

		var distance = global_position.distance_to(player.global_position)
		if distance < attack_distance and not is_dealing_damage:
			deal_damage_to_player()
		elif not is_dealing_damage:
			animated_sprite_2d.play("walk")
	else:
		velocity.x = dir.x * SPEED

		if velocity.x != 0:
			animated_sprite_2d.play("walk")
			animated_sprite_2d.flip_h = velocity.x < 0
		else:
			animated_sprite_2d.play("idle")

	move_and_slide()

func take_damage(amount: int):
	hp -= amount
	health_bar.value = hp

	if hp <= 0:
		die()
	else:
		is_hurt = true
		animated_sprite_2d.play("hurt")
		await get_tree().create_timer(0.3).timeout
		is_hurt = false

func die():
	is_dead = true
	animated_sprite_2d.play("death")
	set_physics_process(false)

	$CollisionShape2D.set_deferred("disabled", true)
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)

	health_bar.visible = false

	await animated_sprite_2d.animation_finished
	queue_free()

func _on_animation_finished():
	if is_dead and animated_sprite_2d.animation == "death":
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		is_chasing = true

func _on_body_exited(body):
	if body == player:
		is_chasing = false
		player = null
		animated_sprite_2d.play("idle")

func deal_damage_to_player():
	if not is_dealing_damage and player and is_instance_valid(player):
		is_dealing_damage = true
		animated_sprite_2d.play("deal_damage")
		player.call_deferred("take_damage", damage_amount)
		await get_tree().create_timer(damage_cooldown).timeout
		is_dealing_damage = false

func _on_direction_timer_timeout():
	if not is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.ZERO])
		if dir == Vector2.ZERO:
			animated_sprite_2d.play("idle")

func choose(array):
	array.shuffle()
	return array.front()

func jump():
	if not is_jumping and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
		jump_timer = MAX_JUMP_TIME
		animated_sprite_2d.play("jump")
