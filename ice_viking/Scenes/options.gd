extends TextureRect

var previous_volume: float = 0.0  # Pohranjuje prethodnu razinu glasnoće

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main_menu.tscn")

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
	previous_volume = value

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))

func _on_mute_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Utišaj zvuk
		AudioServer.set_bus_volume_db(0, -80)
	else:
		# Vrati prethodnu glasnoću
		AudioServer.set_bus_volume_db(0, previous_volume)
