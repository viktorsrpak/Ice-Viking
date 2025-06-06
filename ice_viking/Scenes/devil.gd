extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D  # Referenca na animirani sprite neprijatelja
@onready var detection_area: Area2D = $DetectionArea
@onready var hitbox: Area2D = $Hitbox
@onready var direction_timer = $DirectionTimer
@onready var health_bar: ProgressBar = $Control/HealthBar

const SPEED = 70  							# Brzina kretanja neprijatelja
const GRAVITY = 0  							# Nema gravitacije, lebdi
const JUMP_FORCE = -300  					# Snaga skoka (ne koristi se ovdje)
const MAX_JUMP_TIME = 0.5  					# Maksimalno vrijeme skoka
@export var max_hp := 3  					# Maksimalni HP, može se mijenjati u editoru
var hp: int = max_hp  						# Trenutni HP neprijatelja
var damage_amount = 1  						# Koliko štete nanosi igraču
var is_dealing_damage = false  				# Je li trenutno u napadu
var is_chasing = false  					# Prati li igrača
var dir = Vector2.RIGHT  					# Smjer kretanja (desno/lijevo)
var player = null  							# Referenca na igrača kad ga detektira
var damage_cooldown = 1.0  					# Pauza između napada
var attack_distance = 65  					# Udaljenost za napad
var is_dead: bool = false  					# Je li mrtav
var is_hurt: bool = false  					# Je li trenutno u animaciji ozljede
var is_jumping = false  					# Je li u zraku
var jump_timer = 0.0  						# Timer za skok

const ATTACK_RADIUS = 80  # Radijus u kojem napada igrača

# Inicijalizacija i povezivanje signala
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

# Glavna logika kretanja i napadanja
func _physics_process(delta):
	if is_dead or is_hurt:
		return

	# Ovdje neprijatelj lebdi (nema gravitacije)
	if not is_on_floor():
		velocity.y = 0
		is_jumping = true
	else:
		is_jumping = false
		jump_timer = 0.0

	# Ako vidi igrača, ide prema njemu
	if is_chasing and player and is_instance_valid(player):
		var direction = global_position.direction_to(player.global_position)
		velocity.x = direction.x * SPEED
		animated_sprite_2d.flip_h = direction.x < 0

		var distance = global_position.distance_to(player.global_position)
		print("Udaljenost do igrača: ", distance)

		# Ako je dovoljno blizu, napada
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

	# Ako je preblizu igraču, zaustavi se
	if is_on_floor() and is_chasing and player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player < ATTACK_RADIUS:
			velocity.x = 0
		else:
			velocity.x = dir.x * SPEED

	if not is_on_floor():
		move_and_slide()

	move_and_slide()

# Kad primi štetu, smanjujem HP, animiram hurt ili death
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

# Kad umre, pokrećem animaciju i brišem ga iz scene
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

# Kad igrač uđe u područje detekcije, počinje ga pratiti
func _on_body_entered(body):
	print("Tijelo ušlo u područje: ", body.name)
	if body.is_in_group("Player"):
		player = body
		is_chasing = true
		print("Igrač detektiran od strane neprijatelja!")

# Kad igrač izađe iz područja, prestaje ga pratiti
func _on_body_exited(body):
	if body == player:
		is_chasing = false
		player = null
		animated_sprite_2d.play("idle")
		print("Igrač napustio područje neprijatelja")

# Funkcija za napad na igrača
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

# Timer za promjenu smjera kad ne vidi igrača
func _on_direction_timer_timeout():
	if not is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.ZERO])
		if dir == Vector2.ZERO:
			animated_sprite_2d.play("idle")

func choose(array):
	array.shuffle()
	return array.front()
