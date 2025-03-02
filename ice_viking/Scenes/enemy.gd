extends CharacterBody2D

class_name FrogEnemy

const speed = 30
var is_frog_chase: bool = false

var health = 80
var health_max = 80
var health_min = 0

var dead: bool = false
var taking_damage: bool = false
var damage_to_deal = 20
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 900
var knockback_force = 200
var is_roaming: bool = true

var player: CharacterBody2D  # Referenca na igrača

func _ready():
	if not $DirectionTimer.timeout.is_connected(_on_direction_timer_timeout):
		$DirectionTimer.timeout.connect(_on_direction_timer_timeout)

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta

	move(delta)
	handle_animation()
	move_and_slide()

	# Proverava udaljenost od igrača i započinje praćenje ako je blizu
	if player and global_position.distance_to(player.global_position) < 100:
		is_frog_chase = true
		follow_player(delta)
	else:
		is_frog_chase = false

	# Proverava sudar sa igračem i nanosi štetu
	if is_frog_chase and player and global_position.distance_to(player.global_position) < 70:
		deal_damage_to_player()

func move(delta):
	if !dead:
		if !is_frog_chase:
			velocity += dir * speed * delta
		elif is_frog_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			is_roaming = true
		elif dead:
			velocity.x = 0

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		anim_sprite.play("walk")
		if dir.x == -1:
			anim_sprite.flip_h = true
		elif dir.x == 1:
			anim_sprite.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("hurt")
		await get_tree().create_timer(0.8).timeout  # Čeka 0.8 sekundi pre nego što prestane da prima štetu
		taking_damage = false

		is_roaming = false
		anim_sprite.play("death")
		await get_tree().create_timer(1.0).timeout  # Čeka 1 sekundu pre nego što ukloni neprijatelja iz scene
		handle_death()

func handle_death():
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_frog_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func follow_player(delta):
	if player:
		var dir_to_player = global_position.direction_to(player.global_position)
		velocity.x = dir_to_player.x * speed

func deal_damage_to_player():
	if not is_inside_tree():  # Proverava da li je čvor deo SceneTree-a pre korišćenja get_tree()
		print("Greška: Čvor nije deo SceneTree-a!")
		return

	call_deferred("_delayed_deal_damage")

func _delayed_deal_damage():
	if not is_inside_tree():  # Proverava ponovo za sigurnost
		return

	if not is_dealing_damage:  # Sprečava višestruko nanošenje štete odjednom
		is_dealing_damage = true
		print("Neprijatelj nanosi štetu igraču!")

		player.take_damage(damage_to_deal)

		await get_tree().create_timer(1.0).timeout

		is_dealing_damage = false

# Funkcija za postavljanje reference na igrača (poziva se iz glavne scene)
func set_player(target: CharacterBody2D):
	player = target
