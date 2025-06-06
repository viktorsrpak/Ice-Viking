extends AnimatableBody2D

# Pokreće animaciju platforme
func _ready() -> void:
	$AnimationPlayer.play("move")
