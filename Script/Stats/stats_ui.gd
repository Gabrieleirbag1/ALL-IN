extends CanvasLayer

func _ready() -> void:
	self.visible = false
	EventController.connect("level_up", on_event_level_up)

func on_event_level_up() -> void:
	get_tree().paused = true
	self.visible = true
