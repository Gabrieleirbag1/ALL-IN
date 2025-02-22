extends CanvasLayer

@onready var player: Player = $"../Player"

func _ready() -> void:
	self.visible = false
	EventController.connect("stats_progress", on_event_stats_progress)

func on_event_stats_progress() -> void:
	get_tree().paused = true
	self.visible = true
	var stats = {
		"damage": 0,
		"attack_speed": 0,
		"life_steal": 0,
		"critical": 0,
		"health": 0,
		"speed": 0,
		"luck": 0
	}
	if player is Player:
		player.handle_new_stats(stats)
