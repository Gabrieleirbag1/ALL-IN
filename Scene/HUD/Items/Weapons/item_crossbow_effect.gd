extends ItemEffect

const arrow_scene: PackedScene = preload("res://Scene/Projectiles/Arrow.tscn")

func run():
	cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	var direction = Vector2.RIGHT
	var position = Vector2(0, 0)
	var rotation = 0
	GameController.projectile_throw(arrow_scene, direction, position, rotation)
