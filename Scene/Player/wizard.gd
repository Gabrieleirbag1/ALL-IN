extends Player

func _init() -> void:
	stats = {
	"damage": Global.player_damage,
	"attack_speed": 1,
	"life_steal": 0,
	"critical": Global.player_critical,
	"health": 50,
	"health_max": 50,
	"health_min": 0,
	"speed": 250,
	"experience": 0,
	"luck": Global.luck
	}

	has_spawned_projectile = false
	level = 1
	alive = true
	death_animation_played = false
	immortal = false
	is_taking_damage = false
	invincible = false
	is_attacking = false #related to attack animation
	can_attack = true #related to (projectile) attack_cooldown
