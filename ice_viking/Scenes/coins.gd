extends Area2D

signal coin_colected

func _ready():
	add_to_group("coins")           # Svaki novčić automatski u grupi "coins"
	Global.coins_total += 1         # Svaki novčić povećava ukupni broj novčića

func _on_body_entered(_body: Node2D) -> void:
	Global.score += 1
	Global.coins_collected += 1
	emit_signal("coin_colected")
	queue_free()
