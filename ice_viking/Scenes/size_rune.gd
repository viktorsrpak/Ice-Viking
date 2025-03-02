extends Node2D

func _ready():
	if not $Area2D.body_entered.is_connected(_on_area_2d_body_entered):
		$Area2D.body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("use_scale_power_up"):
			body.use_scale_power_up()
		else:
			print("Greška: Igrač nema funkciju 'use_scale_power_up'")
		queue_free()
