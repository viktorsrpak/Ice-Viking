extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var warning_label = $WarningLabel

func _ready():
	warning_label.visible = false

func activate():
	animated_sprite.frame = 1

func show_warning():
	warning_label.visible = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if Global.coins_collected < Global.coins_total:
			warning_label.visible = true
		else:
			warning_label.visible = false

func _on_body_exited(body):
	if body.is_in_group("Player"):
		warning_label.visible = false
