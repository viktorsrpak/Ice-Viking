extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready():
	if not player:
		print("Greška: Igrač nije pronađen!")
	else:
		print("Igrač pronađen:", player.name)

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")
