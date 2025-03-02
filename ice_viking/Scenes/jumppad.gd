extends Node2D

@export var force = -700.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Provjera da li je objekt koji ulazi u područje igrač (npr. ima određenu grupu)
	if area.get_parent() is CharacterBody2D:
		var character = area.get_parent()
		
		# Provjeri da nije neprijatelj (ako igrač ima grupu 'Player')
		if character.is_in_group("Player"):
			if character.has_method("set_velocity"):
				# Primijeni silu skoka samo na igrača
				character.velocity.y = force
