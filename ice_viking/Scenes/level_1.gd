extends Node2D



func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")
