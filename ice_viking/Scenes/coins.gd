extends Area2D

signal coin_colected  # Signal koji šaljem kad igrač pokupi coin

# Kad igrač pokupi coin, povećavam score i broj coina, šaljem signal i brišem coin iz scene
func _on_body_entered(_body: Node2D) -> void:
	Global.score += 1
	Global.coins_collected += 1
	emit_signal("coin_colected")
	queue_free()
	print("Coin collected:", Global.coins_collected, "/", Global.coins_total)
