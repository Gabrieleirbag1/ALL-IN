extends Projectile

func _init() -> void:
	projectile_range = 1000
	damage = 100
	piercing = false
	animation_name = "start"
	projectile_sound_scene = preload("res://Scene/Sounds/FireballSound.tscn")
