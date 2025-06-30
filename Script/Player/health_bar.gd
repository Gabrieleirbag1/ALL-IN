extends ProgressBar

var player: Player

func _ready():
	EventController.connect("health_update", on_health_update)
	self.visible = false
	player = get_parent()
	set_default_values(player.stats)
	
func set_default_values(player_stats: Dictionary):
	self.max_value = player_stats["health_max"]
	self.min_value = player_stats["health_min"]
	self.value = player_stats["health"]
		
func on_health_update(health_max: int, health_min: int, health: int):
	self.max_value = health_max
	self.min_value = health_min
	self.value = health
	if self.value != self.max_value:
		self.visible = true
		if not player.alive:
			self.queue_free() 
	else:
		self.visible = false
