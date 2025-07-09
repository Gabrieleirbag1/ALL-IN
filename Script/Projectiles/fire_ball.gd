extends Projectile

func _init() -> void:
	projectile_range = 300
	damage = 0
	piercing = false
	animation_name = "fire_ball"
	projectile_sound_scene = preload("res://Scene/Sounds/FireballSound.tscn")

func _on_projectile_sprite_animation_finished() -> void:
	queue_free()
	fade_out_sound()
