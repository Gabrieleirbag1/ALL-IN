extends CanvasLayer

@onready var player: Player = $"../Player"

func _ready() -> void:
	self.visible = false
	EventController.connect("stats_progress", on_event_stats_progress)

func on_event_stats_progress(stats: Dictionary) -> void:
	get_tree().paused = true
	self.visible = true
	if player is Player:
		player.handle_new_stats(stats)
