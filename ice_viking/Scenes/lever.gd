extends Area2D

@onready var animated_sprite = $AnimatedSprite2D  	# Sprite za animaciju poluge
@onready var warning_label = $WarningLabel  		# Labela za upozorenje ako nisu svi coini skupljeni

# Na početku sakrijem warning
func _ready():
	warning_label.visible = false

# Aktivacija poluge
func activate():
	animated_sprite.frame = 1

# Prikaz upozorenja
func show_warning():
	warning_label.visible = true

# Prikaz upozorenja ako igrač nema sve coine
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if Global.coins_collected < Global.coins_total:
			warning_label.visible = true
		else:
			warning_label.visible = false

# Sakrivanje upozorenja kad igrač izađe
func _on_body_exited(body):
	if body.is_in_group("Player"):
		warning_label.visible = false
