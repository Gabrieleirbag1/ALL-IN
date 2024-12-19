extends ProgressBar

var player
var max_value_amount
var min_value_amount

func _ready():
	player = get_parent()
	max_value_amount = player.health_max
	min_value_amount = player.health_min
	
func _process(delta):
	self.value = player.health
	if player.health != max_value_amount:
		self.visible = true
		if not player.alive:
			self.queue_free() 
	else:
		self.visible = false
