extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed: float = 200
var jump_force: float = -400
var gravity: float = 1000
var is_attacking: bool = false # Zastavica za napad

func _ready() -> void:
	# Povezivanje signala za završetak animacije
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	# Ako se napad izvodi, zaustavi sve ostale radnje
	if is_attacking:
		return

	velocity.y += gravity * delta

	# Horizontalno kretanje
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

	# Skakanje
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		animated_sprite_2d.play("jump")

	# Animacije u zraku
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite_2d.play("jump")
		elif velocity.y > 0:
			animated_sprite_2d.play("fall")

	# Napad (samo ako je lik na tlu)
	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		is_attacking = true
		animated_sprite_2d.play("attack")

	# Kretanje pomoću move_and_slide
	move_and_slide()

func _on_animation_finished():
	# Provjeri završenu animaciju
	if animated_sprite_2d.animation == "attack":
		is_attacking = false
