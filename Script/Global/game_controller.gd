extends Node

var total_experience: int = 0

func xp_collected(value: int):
	total_experience += value
	EventController.emit_signal("xp_collected", total_experience)
	
func xp_progress(total_experience: int, min_experience: int, max_experience: int):
	EventController.emit_signal("xp_progress", total_experience, min_experience, max_experience)

func level_up(player_level: int):
	EventController.emit_signal("level_up", player_level)

func stats_progress(stats: Dictionary) -> void:
	EventController.emit_signal("stats_progress", {
		"damage": stats["damage"],
		"attack_speed": stats["attack_speed"],
		"life_steal": stats["life_steal"],
		"critical": stats["critical"],
		"health": stats["health"],
		"speed": stats["speed"],
		"luck": stats["luck"]
	})
	
func enemy_death(xp: int, enemy_position: Vector2, enemy_type: String):
	EventController.emit_signal("enemy_death", xp, enemy_position, enemy_type)
	
func item_trash_display(is_disposable: bool):
	EventController.emit_signal("item_trash_display", is_disposable)
