extends Control

func _ready():
	Global.score = 0
	_update_score_label()

func _update_score_label():
	$Label.text = "COINS: " + str(Global.score)




func _on_coins_coin_colected() -> void:
	_update_score_label()
