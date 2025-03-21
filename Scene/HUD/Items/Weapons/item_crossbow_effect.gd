extends ItemEffect

@onready var arrow_scene: Area2D = $"../Arrow"

func run():
	cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	var main_arrow = arrow_scene.instantiate()
	#arrow_sound.playing = true
	get_parent().add_child(main_arrow)

	main_arrow.direction = Vector2.RIGHT
	main_arrow.global_position = spawn_projectile_right.global_position
