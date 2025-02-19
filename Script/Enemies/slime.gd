# slime.gd
extends "enemy.gd"

func _init() -> void:
	drop_xp = 1
	enemy_type = "slime"
	speed = 50
	knockback_force = 1500
	health = 150
	health_max = 150
	health_min = 0
	damage = 2
	alive = true
	death_animation_played = false
	immortal = false
	player_chase = false
	player = null
