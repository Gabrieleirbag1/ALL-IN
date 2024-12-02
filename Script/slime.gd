# slime.gd
extends "old_enemy.gd"

func _init() -> void:
	speed = 25
	player_chase = false
	player = null
	health = 15
	health_max = 15
	health_min = 0
	damage = 2
	alive = true
	death_animation_played = false
	immortal = false
