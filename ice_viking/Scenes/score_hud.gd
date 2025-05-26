extends Control

func _ready():
	Global.score = 0
	await get_tree().process_frame  # Pričekaj jedan frame da se svi novčići učitaju u scenu
	_update_score_label()
	for coin in get_tree().get_nodes_in_group("coins"):
		if not coin.coin_colected.is_connected(_on_coin_collected):
			coin.coin_colected.connect(_on_coin_collected)

func _update_score_label():
	$Label.text = "SCORE: %d | NOVČIĆI: %d/%d" % [Global.score, Global.coins_collected, Global.coins_total]

func _on_coin_collected():
	_update_score_label()
