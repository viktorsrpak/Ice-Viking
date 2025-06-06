extends AnimatableBody2D

# Pokreće animaciju platforme koja ide ulijevo
func _ready() -> void:
	$AnimationPlayer.play("movetoleft")
