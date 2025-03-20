extends ItemEffect

func run():
	cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	print(1)
