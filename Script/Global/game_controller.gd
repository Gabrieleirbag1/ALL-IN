extends Node

var total_experience: int = 0

func xp_collected(value: int):
	total_experience += value
	EventController.emit_signal("xp_collected", total_experience)
	
func xp_progress(total_experience: int, min_experience: int, max_experience: int):
	EventController.emit_signal("xp_progress", total_experience, min_experience, max_experience)

func enemy_death(xp: int, enemy_position: Vector2):
	EventController.emit_signal("enemy_death", xp, enemy_position)
