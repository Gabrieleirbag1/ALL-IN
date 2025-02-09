extends ProgressBar

func _ready() -> void:
	EventController.connect("xp_progress", on_event_xp_progress)
	
func on_event_xp_progress(total_experience: int, min_experience: int, max_experience: int):
	if total_experience:
		self.value = total_experience
		self.min_value = min_experience
		self.max_value = max_experience
