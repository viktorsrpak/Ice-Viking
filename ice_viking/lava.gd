extends Node2D

func _ready():
	if not $Area2D.body_entered.is_connected(_on_area_2d_body_entered):
		$Area2D.body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Detektovan ulazak:", body.name)  # Debug ispis
	if body.is_in_group("Player"):  # Proverava da li je objekat igrač
		print("Igrač je dotakao lavu!")
		call_deferred("_change_to_game_over")  # Odlaže promenu scene

func _change_to_game_over():
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")  # Prebacuje na game_over.tscn
