extends Control

func _ready():
	Global.score = 0
	_update_score_label()

func _update_score_label():
	$Label.text = "SCORE: " + str(Global.score)


func _on_coins_1_coin_colected() -> void:
	_update_score_label()


func _on_coins_2_coin_colected() -> void:
	_update_score_label()
