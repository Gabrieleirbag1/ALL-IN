extends ProgressBar

var player: Player
var player_stats: Dictionary
var max_value_amount: int
var min_value_amount: int

func _ready():
	player = get_parent()
	player_stats = player.stats
	max_value_amount = player_stats["health_max"]
	min_value_amount = player_stats["health_min"]
	
func _process(_delta):
	self.value = player_stats["health"]
	if player_stats["health"] != max_value_amount:
		self.visible = true
		if not player.alive:
			self.queue_free() 
	else:
		self.visible = false
