extends TextureRect

func _on_quit_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main_menu.tscn")

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(Global.current_level)
