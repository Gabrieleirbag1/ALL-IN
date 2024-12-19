extends Node

var total_experience: int = 0

func xp_collected(value: int):
	total_experience += value
	EventController.emit_signal("xp_collected", total_experience)
