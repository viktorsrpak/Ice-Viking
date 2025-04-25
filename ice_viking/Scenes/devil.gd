extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $Hitbox
@onready var direction_timer = $DirectionTimer
@onready var health_bar: ProgressBar = $Control/HealthBar

const SPEED = 40
const GRAVITY = 0  # Gravitacija na 0, neprijatelj lebdi
const JUMP_FORCE = -300
const MAX_JUMP_TIME = 0.5
@export var max_hp := 3
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

# Dodano: Promjenjiva za udaljenost kada neprijatelj počinje napadati
const ATTACK_RADIUS = 80  # Udaljenost za početak napada

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

	# Neprijatelj je u zraku, bez gravitacije
	if not is_on_floor():
		# Nema gravitacije, neprijatelj lebdi
		velocity.y = 0
		is_jumping = true
	else:
		is_jumping = false
		jump_timer = 0.0  # Resetiraj timer kad se nađe na tlu

	# Ako je neprijatelj u lovu na igrača
	if is_chasing and player and is_instance_valid(player):
		var direction = global_position.direction_to(player.global_position)
		velocity.x = direction.x * SPEED
		animated_sprite_2d.flip_h = direction.x < 0

		var distance = global_position.distance_to(player.global_position)
		print("Udaljenost do igrača: ", distance)

		# Napad kad je igrač unutar opasne udaljenosti
		if distance < ATTACK_RADIUS and not is_dealing_damage:
			print("Pokušavam nanijeti štetu - udaljenost je manja od granice za napad!")
			deal_damage_to_player()
		elif distance >= ATTACK_RADIUS and not is_dealing_damage:
			animated_sprite_2d.play("walk")
	else:
		velocity.x = dir.x * SPEED
		
		if velocity.x != 0:
			animated_sprite_2d.play("walk")
			animated_sprite_2d.flip_h = velocity.x < 0
		else:
			animated_sprite_2d.play("idle")

	# Provjera sudara s igračem i potpuno zaustavljanje neprijatelja kada je preblizu
	if is_on_floor() and is_chasing and player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Ako je neprijatelj preblizu igraču (unutar ATTACK_RADIUS), zaustavi ga
		if distance_to_player < ATTACK_RADIUS:
			velocity.x = 0  # Zaustavi kretanje
		else:
			velocity.x = dir.x * SPEED  # Nastavi kretanje prema igraču

	# Onemogući kretanje prema tlu (guranjem) kad je neprijatelj u zraku
	if not is_on_floor():
		move_and_slide()  # Ne pomičemo ga prema tlu

	move_and_slide()  # Ispravno bez argumenata


func take_damage(amount: int):
	print("Primam štetu! Trenutni HP: ", hp)
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

	# Onemogući sve kolizije
	$CollisionShape2D.set_deferred("disabled", true)
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)

	# Sakrij health bar
	health_bar.visible = false

	# Pričekaj kraj animacije prije brisanja
	await animated_sprite_2d.animation_finished
	queue_free()

func _on_animation_finished():
	if is_dead and animated_sprite_2d.animation == "death":
		queue_free()

func _on_body_entered(body):
	print("Tijelo ušlo u područje: ", body.name)
	if body.is_in_group("Player"):
		player = body
		is_chasing = true
		print("Igrač detektiran od strane neprijatelja!")

func _on_body_exited(body):
	if body == player:
		is_chasing = false
		player = null
		animated_sprite_2d.play("idle")
		print("Igrač napustio područje neprijatelja")

func deal_damage_to_player():
	if not is_dealing_damage and player and is_instance_valid(player):
		is_dealing_damage = true
		print("Neprijatelj započinje napad!")
		animated_sprite_2d.play("deal_damage")
		player.call_deferred("take_damage", damage_amount)
		print("Šteta nanesena igraču: ", damage_amount)
		await get_tree().create_timer(damage_cooldown).timeout
		is_dealing_damage = false
		print("Neprijatelj je spreman za novi napad")

func _on_direction_timer_timeout():
	if not is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.ZERO])
		if dir == Vector2.ZERO:
			animated_sprite_2d.play("idle")

func choose(array):
	array.shuffle()
	return array.front()

# Funkcija za skakanje (ako je potrebno)
func jump():
	if not is_jumping and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
		jump_timer = MAX_JUMP_TIME
		animated_sprite_2d.play("jump")  # Ako postoji animacija za skakanje
