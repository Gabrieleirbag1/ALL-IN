extends Node

signal xp_collected(value: int)
signal xp_progress(total_experience: int, min_experience: int, max_experience: int)
signal level_up(player_level: int)
signal health_update(health_max: int, health: int)
signal stats_progress(stats: Dictionary)
signal lucky_event(lucky_event_category: String, lucky_block_position: Vector2)
signal enemy_death(xp: int, enemy_position: Vector2, enemy_type: String)
signal item_trash_display(is_disposable: bool)
signal projectile_throw(projectile_scene: PackedScene, projectile_direction: Vector2, projectile_position: Vector2, projectile_rotation: int)
