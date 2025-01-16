extends Area2D

signal coin_colected

func _on_body_entered(body: Node2D) -> void:
	Global.score += 1
	emit_signal("coin_colected")
	queue_free()
