extends Node2D

func _ready() -> void:
	Global.total_coins = get_tree().get_nodes_in_group("coins").size()
	Global.coins_collected = 0

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_lever_body_entered(_body: Node2D) -> void:
	if Global.coins_collected >= Global.total_coins:
		$Lever/AnimatedSprite2D.frame = 1
		$Portal/AnimationPlayer.play("Slide")
	else:
		print("Nisi pokupio sve coine!")

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if Global.coins_collected >= Global.total_coins:
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/Level_1.tscn")
	else:
		print("Svi coinsi nisu pokupljeni!")
