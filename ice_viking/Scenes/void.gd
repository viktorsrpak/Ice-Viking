extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game_over.tscn")
