extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $Camera2D/HealthBar

var speed: float = 200
var jump_force: float = -400
var gravity: float = 1000
var hp = 5  # Početno zdravlje igrača

func _ready() -> void:
	health_bar.value = hp

func _physics_process(delta: float) -> void:
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

	move_and_slide()

func take_damage(amount: int) -> void:
	hp -= amount
	print("Igrač je primio štetu! Preostalo zdravlje: {hp}")
	health_bar.value = hp

	if hp <= 0:
		die()

func die() -> void:
	print("Igrač je umro!")
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")  # Prebacuje scenu na game_over.tscn

# Funkcije za Power-Up-ove
func use_jump_power_up():
	print("Funkcija use_jump_power_up() je pozvana!")
	var powerUpDuration = 5  # Trajanje efekta power-up-a

	jump_force *= 1.5  # Povećava snagu skoka

	await get_tree().create_timer(powerUpDuration).timeout

	jump_force /= 1.5  # Vraća snagu skoka na početnu vrednost

func use_speed_power_up():
	print("Funkcija use_speed_power_up() je pozvana!")
	var powerUpDuration = 5  # Trajanje efekta power-up-a

	speed *= 1.5  # Povećava brzinu

	await get_tree().create_timer(powerUpDuration).timeout

	speed /= 1.5  # Vraća brzinu na početnu vrednost

func use_scale_power_up():
	print("Funkcija use_scale_power_up() je pozvana!")
	var powerUpDuration = 5  # Trajanje efekta power-up-a

	animated_sprite_2d.scale *= 1.5  # Povećava veličinu igrača

	await get_tree().create_timer(powerUpDuration).timeout

	animated_sprite_2d.scale /= 1.5  # Vraća veličinu igrača na početnu vrednost
