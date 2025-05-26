extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready():
	Global.current_level = "res://Scenes/Level_3.tscn"
	Global.coins_total = get_tree().get_nodes_in_group("coins").size()
	Global.coins_collected = 0

	if not player:
		print("Greška: Igrač nije pronađen!")
	else:
		print("Igrač se stvorio: ", player.name)

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_lever_body_entered(_body: Node2D) -> void:
	if Global.coins_collected >= Global.coins_total:
		$Lever/AnimatedSprite2D.frame = 1
		$Portal/AnimationPlayer.play("Slide")
	else:
		print("Nisi pokupio sve coine!")

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if Global.coins_collected >= Global.coins_total:
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/main_menu.tscn")
	else:
		print("Svi coinsi nisu pokupljeni!")

func game_over():
	Global.current_level = "res://Scenes/Level_3.tscn"
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
