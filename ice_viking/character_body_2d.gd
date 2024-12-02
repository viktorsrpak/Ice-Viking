extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed: float = 200 # Horizontalna brzina
var jump_force: float = -400 # Sila skoka
var gravity: float = 1000 # Gravitacija

func _physics_process(delta: float) -> void:
	# Dodavanje gravitacije
	velocity.y += gravity * delta

	# Horizontalno kretanje
	if Input.is_action_pressed("move_right"):
		velocity.x = speed
		animated_sprite_2d.flip_h = false # Gledaj desno
		if is_on_floor():
			animated_sprite_2d.play("walking_right")
	elif Input.is_action_pressed("move_left"):
		velocity.x = -speed
		animated_sprite_2d.flip_h = true # Gledaj lijevo
		if is_on_floor():
			animated_sprite_2d.play("walking_left")
	else:
		velocity.x = 0
		if is_on_floor():
			animated_sprite_2d.play("stand") # Postavljanje animacije na "stand" kada se ne pomiče

	# Skakanje
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		animated_sprite_2d.play("jump") # Pokreni animaciju skoka

	# Animacije u zraku
	if not is_on_floor():
		if velocity.y < 0: # Ako se kreće prema gore
			animated_sprite_2d.play("jump")
		elif velocity.y > 0: # Ako pada prema dolje
			animated_sprite_2d.play("fall")

	# Kretanje pomoću move_and_slide
	move_and_slide()
