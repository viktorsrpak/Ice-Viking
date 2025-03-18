extends Node2D

@export var jump_force = -700.0
@export var detection_width = 40    # Širina detekcije (središnji dio)
@export var vertical_offset = -20   # Pomak prema gore od platforme
@export var detection_height = 10   # Visina detekcije

func _ready():
	if not has_node("Area2D") or not $Area2D.has_node("CollisionShape2D"):
		push_error("JumpPad nema potrebnu strukturu čvorova!")
		return
	
	var shape = $Area2D/CollisionShape2D.shape
	if shape is RectangleShape2D:
		# Smanjujemo širinu detekcije na središnji dio
		shape.extents.x = detection_width / 2  # extents su POLOVINA širine!
		shape.extents.y = detection_height
		
		# Centriramo detektor i pomičemo ga točno iznad platforme
		$Area2D/CollisionShape2D.position = Vector2(0, vertical_offset)
	
	if not $Area2D.body_entered.is_connected(on_body_entered):
		$Area2D.body_entered.connect(on_body_entered)

func on_body_entered(body):
	if body is CharacterBody2D and body.is_in_group("Player"):
		# Dodatna provjera y-brzine da spriječi skok u letu
		if body.velocity.y >= 0:  # Aktiviraj samo kada igrač pada
			body.velocity.y = jump_force
			print("Točan skok aktiviran")
