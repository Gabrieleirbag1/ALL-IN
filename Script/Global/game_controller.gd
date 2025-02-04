extends Node

var total_experience: int = 0

func xp_collected(value: int):
	total_experience += value
	EventController.emit_signal("xp_collected", total_experience)
	
func enemy_death(xp: int, enemy_position: Vector2, enemy_type: String):
	EventController.emit_signal("enemy_death", xp, enemy_position, enemy_type)
