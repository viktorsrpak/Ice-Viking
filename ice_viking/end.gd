extends Node2D

# Ova skripta je za kraj igre, kad igrač dođe do kraja levela
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

# Kad igrač uđe u područje, prebaci ga na win scenu
func _on_area_2d_body_entered(_body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/win.tscn")
