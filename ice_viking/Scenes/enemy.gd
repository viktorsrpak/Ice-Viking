extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_area = $Area2D
@onready var direction_timer = $DirectionTimer

const SPEED = 40
const GRAVITY = 900
var damage_amount = 1
var is_dealing_damage = false
var is_chasing = false
var dir = Vector2.RIGHT
var player = null
var damage_cooldown = 1.0
var attack_distance = 65  # Povećana udaljenost na temelju debug ispisa

func _ready():
	if not detection_area:
		push_error("Area2D nije pronađena! Provjerite strukturu čvorova.")
		return
		
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	
	if not direction_timer.timeout.is_connected(_on_direction_timer_timeout):
		direction_timer.timeout.connect(_on_direction_timer_timeout)
	
	animated_sprite_2d.play("idle")
	print("Neprijatelj je inicijaliziran")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if is_chasing and player and is_instance_valid(player):
		var direction = global_position.direction_to(player.global_position)
		velocity.x = direction.x * SPEED
		
		animated_sprite_2d.flip_h = direction.x < 0
		
		var distance = global_position.distance_to(player.global_position)
		print("Udaljenost do igrača: ", distance)
		
		if distance < attack_distance and not is_dealing_damage:
			print("Pokušavam nanijeti štetu - udaljenost je manja od granice za napad!")
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
		
		# Koristimo call_deferred za sigurno pozivanje tijekom fizičkog procesa
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
