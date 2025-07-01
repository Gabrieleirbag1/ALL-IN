extends Node

var total_experience: int = 0

func xp_collected(value: int):
	total_experience += value
	EventController.emit_signal("xp_collected", total_experience)
	
func xp_progress(total_experience_value: int, min_experience: int, max_experience: int):
	EventController.emit_signal("xp_progress", total_experience_value, min_experience, max_experience)

func level_up(player_level: int):
	EventController.emit_signal("level_up", player_level)
	
func health_update(health_max: int, health: int):
	EventController.emit_signal("health_update", health_max, health)
	
func enemy_damaged_event(damage_amount: int, alive: bool):
	EventController.emit_signal("enemy_damaged_event", damage_amount, alive)

func stats_progress(stats: Dictionary) -> void:
	EventController.emit_signal("stats_progress", {
		"damage": stats["damage"],
		"attack_speed": stats["attack_speed"],
		"life_steal": stats["life_steal"],
		"critical": stats["critical"],
		"health_max": stats["health_max"],
		"speed": stats["speed"],
		"luck": stats["luck"]
	})
	
func lucky_event(lucky_event_category: String, lucky_block_position: Vector2):
	EventController.emit_signal("lucky_event", lucky_event_category, lucky_block_position)
	
func enemy_death(xp: int, enemy_position: Vector2, enemy_type: String):
	EventController.emit_signal("enemy_death", xp, enemy_position, enemy_type)
	
func item_trash_display(is_disposable: bool):
	EventController.emit_signal("item_trash_display", is_disposable)
	
func projectile_throw(projectile_scene: PackedScene, projectile_direction: Vector2, projectile_position: Vector2, projectile_rotation: int):
	EventController.emit_signal("projectile_throw", projectile_scene, projectile_direction, projectile_position, projectile_rotation)
