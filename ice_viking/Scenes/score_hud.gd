extends Control

# Postavljam početni score i prikaz na ekranu
func _ready():
	Global.score = 0
	_update_score_label()

# Ažuriranje prikaza score-a
func _update_score_label():
	$Label.text = "SCORE: " + str(Global.score)

# Osvježavanje score-a kad se pokupi coin
func _on_coins_1_coin_colected() -> void:
	_update_score_label()

func _on_coins_2_coin_colected() -> void:
	_update_score_label()

func _on_coins_1_coin_collected() -> void:
	_update_score_label()
