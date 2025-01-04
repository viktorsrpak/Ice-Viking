extends Node2D

@export var force = -700.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Check if the entered area belongs to a CharacterBody2D
	if area.get_parent() is CharacterBody2D:
		var character = area.get_parent()
		if character.has_method("set_velocity"):
			# Apply the jump force in the Y direction
			character.velocity.y = force
