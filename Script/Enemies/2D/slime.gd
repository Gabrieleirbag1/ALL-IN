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
	ability_attack_damage = 20
	alive = true
	death_animation_played = false
	immortal = false
	player_chase = false
	player = null

func on_ability_attack():
	if animation.animation.begins_with("attack"):
		if animation.frame > 5 and animation.frame < 8 and player_in_range: #frame 6 7
			# Use position-based direction for knockback since velocity is 0 during attack
			var knockback_direction = (player.global_position - global_position).normalized() * speed
			player.enemy_attack(knockback_direction, knockback_force, ability_attack_damage)
