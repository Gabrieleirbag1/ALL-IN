# beholder.gd
extends Enemy

func _init() -> void:
	drop_xp = 10
	enemy_type = "beholder"
	speed = 20
	knockback_force = 2500
	health = 300
	health_max = 300
	health_min = 0
	damage = 10
	ability_attack_damage = 20
	ability_attack_cooldown = 3
	min_ability_attack_frame = 2
	max_ability_attack_frame = 5
