extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $Camera2D/HealthBar

var speed: float = 200
var jump_force: float = -400
var gravity: float = 1000
var hp = 5

var is_attacking: bool = false  # Zastavica za praćenje izvođenja napada
var attack_duration: float = 0.5  # Trajanje napada u sekundama
var attack_timer: float = 0.0  # Timer za napad

func _ready() -> void:
	health_bar.value = hp

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
		is_attacking = true
		attack_timer = attack_duration
		animated_sprite_2d.play("attack")

	move_and_slide()

func take_damage(amount: int) -> void:
	print("Funkcija take_damage pozvana s iznosom: " + str(amount))
	hp -= amount
	print("Igrač je primio štetu! Preostali health: " + str(hp))
	health_bar.value = hp

	if hp <= 0:
		die()

func die() -> void:
	print("Igrač je umro!")
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

# Funkcije za Power-Up-ove
func use_jump_power_up():
	print("Funkcija use_jump_power_up() je pozvana!")
	var powerUpDuration = 5

	jump_force *= 1.5

	await get_tree().create_timer(powerUpDuration).timeout

	jump_force /= 1.5
	

func use_speed_power_up():
	print("Funkcija use_speed_power_up() je pozvana!")
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
