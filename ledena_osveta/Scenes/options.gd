extends TextureRect


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main_menu.tscn")
