extends ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventController.connect("xp_progress", on_event_xp_progress)
	
func on_event_xp_progress(total_experience: int, min_experience: int, max_experience: int):
	if total_experience:
		self.value = total_experience
		self.min_value = min_experience
		self.max_value = max_experience


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
