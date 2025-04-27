extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var attack_range: Area2D = $AttackRange
@onready var health_bar = $Camera2D/HealthBar  # ISPRAVNO



var speed: float = 200
var jump_force: float = -400
var gravity: float = 1000
var hp = 5
var attack_damage: int = 1

var is_attacking: bool = false
var attack_duration: float = 0.5
var attack_timer: float = 0.0





func _ready() -> void:
	health_bar.value = hp
	attack_range.body_entered.connect(_on_attack_range_body_entered)

func _physics_process(delta: float) -> void:
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
		return
	
	velocity.y += gravity * delta

	if Input.is_action_pressed("move_right"):
		velocity.x = speed
		animated_sprite_2d.flip_h = false
		if is_on_floor():
			animated_sprite_2d.play("walking_right")
	elif Input.is_action_pressed("move_left"):
		velocity.x = -speed
		animated_sprite_2d.flip_h = true
		if is_on_floor():
			animated_sprite_2d.play("walking_left")
	else:
		velocity.x = 0
		if is_on_floor():
			animated_sprite_2d.play("stand")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		animated_sprite_2d.play("jump")
		
	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		start_attack()

	move_and_slide()

func start_attack():
	is_attacking = true
	attack_timer = attack_duration
	animated_sprite_2d.play("attack")
	check_attack()

func check_attack():
	var overlapping_areas = attack_range.get_overlapping_areas() 
	
	for area in overlapping_areas:
		if area.is_in_group("EnemyHitbox"):
			var enemy = area.get_parent()
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)


func _on_attack_range_body_entered(body):
	if is_attacking and body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	hp -= amount
	health_bar.value = hp

	if hp <= 0:
		die()

func die() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func use_jump_power_up():
	print("Funkcija use_jump_power_up() je pozvana!")
	var powerUpDuration = 5

	jump_force *= 1.5

	await get_tree().create_timer(powerUpDuration).timeout

	jump_force /= 1.5

func use_speed_power_up():
	var powerUpDuration = 5

	speed *= 1.5

	await get_tree().create_timer(powerUpDuration).timeout

	speed /= 1.5

func use_scale_power_up():
	print("Funkcija use_scale_power_up() je pozvana!")
	var powerUpDuration = 5

	animated_sprite_2d.scale *= 1.5

	await get_tree().create_timer(powerUpDuration).timeout

	animated_sprite_2d.scale /= 1.5
