extends Node2D

@export var jump_force = -700.0
@export var detection_height = 100  # Visina detektora iznad jumppada

func _ready():
	# Provjera strukture čvorova
	if not has_node("Area2D") or not $Area2D.has_node("CollisionShape2D"):
		push_error("JumpPad nema potrebnu strukturu čvorova!")
		return
	
	# Povećaj visinu collision shape-a
	var shape = $Area2D/CollisionShape2D.shape
	if shape is RectangleShape2D:
		# Značajno povećaj visinu pravokutnika za detekciju
		shape.extents.y = detection_height
		# Pomakni collision shape prema gore da obuhvati prostor iznad jumppada
		$Area2D/CollisionShape2D.position.y = -detection_height
	
	# Povezivanje signala za detekciju igrača
	if not $Area2D.body_entered.is_connected(on_body_entered):
		$Area2D.body_entered.connect(on_body_entered)
	
	print("JumpPad inicijaliziran!")

func on_body_entered(body):
	print("Tijelo ušlo u jumppad: ", body.name)
	
	# Provjeri je li tijelo igrač
	if body is CharacterBody2D and body.is_in_group("Player"):
		print("Igrač aktivirao jumppad!")
		
		# Izračunaj odgovarajuću silu odskoka
		var bounce_force = jump_force
		
		# Ako igrač pada brzo, odbij ga jače
		if body.velocity.y > 200:
			bounce_force = -body.velocity.y * 1.2
			print("Jači odskok zbog brzine pada: ", bounce_force)
		
		# Primijeni silu skoka
		body.velocity.y = bounce_force
		
		# Pokreni animaciju aktivacije ako postoji
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("activate")
		
		# Reproduciraj zvuk ako postoji
		if has_node("AudioStreamPlayer2D"):
			$AudioStreamPlayer2D.play()
