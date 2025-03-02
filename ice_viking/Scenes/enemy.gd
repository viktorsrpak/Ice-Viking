extends CharacterBody2D

@export var speed: float = 100
@export var gravity: float = 1000
@export var damage_interval: float = 1.0

var direction := Vector2.LEFT
var player_in_range: Node2D = null
var state: String = "walk"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer

func _ready():
	if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.wait_time = damage_interval
	attack_timer.one_shot = false
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	velocity.y += gravity * delta
	
	match state:
		"walk":
			move_and_walk()
		"attack":
			velocity.x = 0  # Neprijatelj stane dok napada

	move_and_slide()

func move_and_walk():
	var collision = move_and_collide(direction * speed * get_physics_process_delta_time())
	if collision:
		# Povuci neprijatelja malo unatrag prije nego što se okrene
		position -= direction * 10
		flip_direction()
	else:
		velocity.x = direction.x * speed
		play_animation("Walk")

func flip_direction():
	# Provjera ako je neprijatelj već u zidu
	if is_on_wall():
		position += direction * 5  # Povlači ga iz zida
	direction.x *= -1
	sprite.flip_h = !sprite.flip_h

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		player_in_range = body
		set_state("attack")
		attack_timer.start()
		_on_attack_timer_timeout()

func _on_area_2d_body_exited(body: Node2D):
	if body == player_in_range:
		reset_attack_state()

func _on_attack_timer_timeout():
	if player_in_range and player_in_range.is_inside_tree():
		if player_in_range.has_method("take_damage"):
			player_in_range.take_damage(1)
			play_animation("Attack")
	else:
		reset_attack_state()

func reset_attack_state():
	player_in_range = null
	set_state("walk")
	attack_timer.stop()

func play_animation(anim_name: String):
	if sprite.animation != anim_name or sprite.is_playing() == false:
		sprite.play(anim_name)

func set_state(new_state: String):
	if state != new_state:
		state = new_state

func _on_animation_finished():
	if state == "attack":
		play_animation("Attack")
