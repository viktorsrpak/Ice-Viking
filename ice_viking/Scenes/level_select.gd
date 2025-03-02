extends TextureRect


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_1.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_2.tscn")


func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_3.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")


func _on_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main_menu.tscn")
