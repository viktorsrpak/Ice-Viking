extends Area2D

signal coin_colected

func _on_body_entered(_body: Node2D) -> void:
	Global.score += 1
	Global.coins_collected += 1
	emit_signal("coin_colected")
	queue_free()
	print("Coin collected:", Global.coins_collected, "/", Global.coins_total)
