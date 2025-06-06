extends Node

# Ovdje su globalne varijable za score, trenutni level i coine
var score: int = 0  # Rezultat igrača
var current_level: String = "res://Scenes/Level_1.tscn"  # Putanja do trenutnog levela
var coins_total: int = 0  # Ukupan broj coina na levelu
var coins_collected: int = 0  # Broj skupljenih coina

# Funkcija za resetiranje coina (koristim kad prelazim level)
func reset_coins():
	coins_total = 0
	coins_collected = 0
