extends CanvasLayer

var score: int = 0

func _ready() -> void:
	$Score.text = "Score : " + str(score)
	EventController.connect("enemy_death", Callable(self, "on_enemy_death"))
	#print("Signal enemy_death connecté dans Score.gd")

func on_enemy_death(xp: int, enemy_position: Vector2, enemy_type: String) -> void:
	#print("Enemy death signal reçu: type=%s, xp=%d" % [enemy_type, xp])
	if enemy_type == "slime":
		score += 100
		$Score.text = "Score : " + str(score)
	elif enemy_type == "orc":
			score += 200
			$Score.text = "Score : " + str(score)
	else:
		print("Type d'ennemi inconnu : ", enemy_type)
