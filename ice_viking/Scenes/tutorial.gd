extends Node2D



func _ready() -> void:
	pass 




func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")


func _on_lever_body_entered(_body: Node2D) -> void:
	$Lever/AnimatedSprite2D.frame = 1
	$Portal/AnimationPlayer.play("Slide")


func _on_area_2d_body_entered(_body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/Level_1.tscn")
