# slime.gd
extends Enemy

func _init() -> void:
	drop_xp = 10
	enemy_type = "slime"
	speed = 50
	knockback_force = 1500
	health = 150
	health_max = 150
	health_min = 0
	damage = 2
	ability_attack_damage = 7
	ability_attack_cooldown = 2
	min_ability_attack_frame = 6
	max_ability_attack_frame = 7
	
