extends Node

var score: int = 0
var current_level: String = "res://Scenes/Level_1.tscn"
var coins_total: int = 0
var coins_collected: int = 0

func reset_coins():
	coins_total = 0
	coins_collected = 0
