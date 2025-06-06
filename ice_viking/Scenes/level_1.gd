extends Node2D  # Skripta za upravljanje levelom

@onready var player = get_tree().get_first_node_in_group("Player")  # Dohvaćam igrača iz scene

func _ready():
	# Postavljam osnovne podatke o levelu i coinima na početku igre
	Global.current_level = "res://Scenes/Level_1.tscn"
	Global.coins_total = get_tree().get_nodes_in_group("coins").size()
	Global.coins_collected = 0
	print("Total coins in scene:", Global.coins_total)

	if not player:
		print("Greška: Igrač nije pronađen!")
	else:
		print("Igrač se stvorio: ", player.name)

func _on_menu_button_pressed() -> void:
	# Povratak na izbornik levela
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_lever_body_entered(_body: Node2D) -> void:
	# Ako su svi coini skupljeni, aktiviram polugu i portal, inače pokazujem upozorenje
	if Global.coins_collected >= Global.coins_total:
		$Lever.activate()
		$Portal/AnimationPlayer.play("Slide")
	else:
		$Lever.show_warning()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	# Provjeravam jesu li svi coini skupljeni prije prelaska na sljedeći level
	if Global.coins_collected >= Global.coins_total:
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Level_2.tscn")
	else:
		print("Svi coinsi nisu pokupljeni!")

func game_over():
	# Prebacujem igru na game over scenu i spremam trenutni level
	Global.current_level = "res://Scenes/Level_1.tscn"
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
