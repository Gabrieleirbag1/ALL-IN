extends ItemEffect

func run():
	print(0)
	cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	print(1)
