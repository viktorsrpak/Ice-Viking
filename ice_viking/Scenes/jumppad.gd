extends Node2D

@export var jump_force = -700.0  		# Snaga odbacivanja igrača prema gore
@export var detection_width := 40.0  	# Širina detekcijskog područja
@export var vertical_offset := -20.0 	# Vertikalni pomak detekcijskog područja
@export var detection_height := 10.0  	# Visina detekcijskog područja

# Prilagodba veličine detekcijskog područja i povezivanje signala
func _ready():
	if not has_node("Area2D") or not $Area2D.has_node("CollisionShape2D"):
		push_error("JumpPad nema potrebnu strukturu čvorova!")
		return
	
	var shape = $Area2D/CollisionShape2D.shape
	if shape is RectangleShape2D:
		shape.extents.x = detection_width / 2.0
		shape.extents.y = detection_height
		$Area2D/CollisionShape2D.position = Vector2(0, vertical_offset)
	
	if not $Area2D.body_entered.is_connected(on_body_entered):
		$Area2D.body_entered.connect(on_body_entered)

# Kad igrač stane na jump pad, odbacuje ga u zrak
func on_body_entered(body):
	if body is CharacterBody2D and body.is_in_group("Player"):
		if body.velocity.y >= 0:  
			body.velocity.y = jump_force
