extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_range: Area2D = $AttackRange
@onready var health_bar = $Camera2D/HealthBar

# Osnovne varijable za kretanje, skok, zdravlje i napad
var speed: float = 200  		# Brzina kretanja igrača
var jump_force: float = -400  	# Snaga skoka
var gravity: float = 1000  		# Gravitacija
var hp = 5  					# Broj za hp
var attack_damage: int = 1  	# Šteta koju igrač nanosi neprijatelju

var is_attacking: bool = false  	# Je li igrač trenutno u napadu
var attack_duration: float = 0.5  	# Trajanje napada u sekundama
var attack_timer: float = 0.0  		# Timer za napad

# U ready postavljam health bar i povezujem signal za napad
func _ready() -> void:
	health_bar.value = hp
	attack_range.body_entered.connect(_on_attack_range_body_entered)

# Ovdje rješavam kretanje, skakanje i napadanje
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

# Kad igrač napada, pokrećem animaciju i provjeravam je li pogodio neprijatelja
func start_attack():
	is_attacking = true
	attack_timer = attack_duration
	animated_sprite_2d.play("attack")
	check_attack()

# Provjeravam ima li neprijatelja u dometu napada
func check_attack():
	var overlapping_areas = attack_range.get_overlapping_areas() 
	for area in overlapping_areas:
		if area.is_in_group("EnemyHitbox"):
			var enemy = area.get_parent()
			if enemy.has_method("take_damage"):
				enemy.take_damage(attack_damage)

# Ako je neprijatelj ušao u attack_range dok napadam, nanesi štetu
func _on_attack_range_body_entered(body):
	if is_attacking and body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(attack_damage)

# Kad igrač primi štetu, smanjujem HP i provjeravam je li mrtav
func take_damage(amount: int) -> void:
	hp -= amount
	health_bar.value = hp

	if hp <= 0:
		die()

# Kad igrač umre, prebacujem na game over scenu
func die() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

# Power-up za skok - privremeno povećavam jump_force
func use_jump_power_up():
	print("Funkcija use_jump_power_up() je pozvana!")
	var powerUpDuration = 5
	jump_force *= 1.5
	await get_tree().create_timer(powerUpDuration).timeout
	jump_force /= 1.5

# Power-up za brzinu
func use_speed_power_up():
	var powerUpDuration = 5
	speed *= 1.5
	await get_tree().create_timer(powerUpDuration).timeout
	speed /= 1.5

# Power-up za veličinu i jačinu napada
func use_scale_power_up():
	print("Funkcija use_scale_power_up() je pozvana!")
	var powerUpDuration = 5
	animated_sprite_2d.scale *= 1.2
	attack_damage += 3
	await get_tree().create_timer(powerUpDuration).timeout
	animated_sprite_2d.scale /= 1.2
	attack_damage -= 3
