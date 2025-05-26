extends Node2D

var lever_opened = false
@onready var player = get_tree().get_first_node_in_group("Player")

func _ready():
	Global.current_level = "res://Scenes/Level_3.tscn"
	Global.reset_coins()
	lever_opened = false
	$Portal/Area2D.set_deferred("monitoring", false)  # Portal je zatvoren dok lever nije otvoren

	if not player:
		print("Greška: Igrač nije pronađen!")
	else:
		print("Igrač se stvorio: ", player.name)

	# Ažuriraj HUD nakon što su svi novčići učitani
	await get_tree().process_frame
	if has_node("ScoreHUD"):
		$ScoreHUD._update_score_label()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_lever_body_entered(_Node2D) -> void:
	if Global.coins_collected >= Global.coins_total and Global.coins_total > 0 and not lever_opened:
		$Lever/AnimatedSprite2D.frame = 1
		$Portal/AnimationPlayer.play("Slide")
		lever_opened = true
		$Portal/Area2D.set_deferred("monitoring", true)  # Omogući ulazak u portal
	else:
		print("Moraš skupiti sve novčiće prije otvaranja poluge!")

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if lever_opened:
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/main_menu.tscn")
	else:
		print("Portal je zatvoren! Prvo otvori lever.")

func game_over():
	Global.current_level = "res://Scenes/Level_3.tscn"
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
