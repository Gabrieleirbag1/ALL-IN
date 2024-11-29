# slime.gd
extends "enemy.gd"

func _init() -> void:
	speed = 50
	player_chase = false
	player = null
	health = 50
	health_max = 50
	health_min = 0
	alive = true
	death_animation_played = false
	immortal = false
