extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready():
	Global.current_level = "res://Scenes/Level_1.tscn"
	if not player:
		print("Greška: Igrač nije pronađen!")
	else:
		print("Igrač se stvorio: ", player.name)

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_lever_body_entered(_Node2D) -> void:
	$Lever/AnimatedSprite2D.frame = 1
	$Portal/AnimationPlayer.play("Slide")

func _on_area_2d_body_entered(_body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/Level_2.tscn")

func game_over():
	Global.current_level = "res://Scenes/Level_1.tscn"
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
