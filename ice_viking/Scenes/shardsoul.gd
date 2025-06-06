extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $Hitbox
@onready var direction_timer = $DirectionTimer
@onready var health_bar: ProgressBar = $Control/HealthBar
@onready var ledge_ray: RayCast2D = $LedgeRay

# Boss neprijatelj, ima više HP-a i koristi raycast za rubove platforme
const SPEED = 40  			# Brzina kretanja bossa
const GRAVITY = 900  		# Gravitacija
const JUMP_FORCE = -300  	# Snaga skoka
const MAX_JUMP_TIME = 0.5  	# Maksimalno trajanje skoka
@export var max_hp := 10  	# Maksimalni HP bossa, može se mijenjati u editoru
var hp: int = max_hp  		# Trenutni HP
var damage_amount = 1  		# Šteta koju boss nanosi igraču
var is_dealing_damage = false  		# Je li u napadu
var is_chasing = false  			# Prati li igrača
var dir = Vector2.RIGHT  			# Smjer kretanja
var player = null  					# Referenca na igrača
var damage_cooldown = 1.0  			# Pauza između napada
var attack_distance = 65  			# Udaljenost za napad
var is_dead: bool = false  			# Je li mrtav
var is_hurt: bool = false  			# Je li u animaciji ozljede
var is_jumping = false  			# Je li u zraku
var jump_timer = 0.0  				# Timer za skok

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

# Glavna logika kretanja, napadanja, gravitacije i raycast za rubove
func _physics_process(delta):
	if is_dead or is_hurt:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
		is_jumping = true
	else:
		is_jumping = false
		jump_timer = 0.0

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
		update_ledge_ray_direction()
		if ledge_ray.is_colliding():
			velocity.x = dir.x * SPEED
			if velocity.x != 0:
				animated_sprite_2d.play("walk")
				animated_sprite_2d.flip_h = velocity.x < 0
			else:
				animated_sprite_2d.play("idle")
		else:
			velocity.x = 0
			animated_sprite_2d.play("idle")

	move_and_slide()

# Ažuriranje smjera raycasta za provjeru ruba platforme
func update_ledge_ray_direction():
	if dir == Vector2.RIGHT:
		ledge_ray.position.x = 8
		ledge_ray.target_position = Vector2(0, 16)
	elif dir == Vector2.LEFT:
		ledge_ray.position.x = -8
		ledge_ray.target_position = Vector2(0, 16)
	else:
		ledge_ray.position.x = 0
		ledge_ray.target_position = Vector2(0, 16)

# Primanje štete
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

# Smrt bossa
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

# Napad na igrača
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

# Skakanje bossa (ako je potrebno)
func jump():
	if not is_jumping and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
		jump_timer = MAX_JUMP_TIME
		animated_sprite_2d.play("jump")
