# orc.gd
extends Enemy

func _init() -> void:
	drop_xp = 10
	enemy_type = "orc"
	speed = 20
	knockback_force = 2500
	health = 300
	health_max = 300
	health_min = 0
	damage = 10
	alive = true
	death_animation_played = false
	immortal = false
	player_chase = false
	player = null
