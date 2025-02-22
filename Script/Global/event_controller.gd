extends Node

signal xp_collected(value: int)
signal xp_progress(total_experience: int, min_experience: int, max_experience: int)
signal level_up()
signal stats_progress(stats: Dictionary)
signal enemy_death(xp: int, enemy_position: Vector2, enemy_type: String)
