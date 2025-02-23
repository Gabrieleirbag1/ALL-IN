extends CanvasLayer

@onready var item_icons = [
	$Stat1/StatFrame/TextureRect/ItemIcon,
	$Stat2/StatFrame/TextureRect/ItemIcon,
	$Stat3/StatFrame/TextureRect/ItemIcon
]
var stats_icon_path = "res://Assets/Stats/icons/png180x/"
var stats: Dictionary = {
	"damage": 0, 
	"attack_speed": 0, 
	"life_steal": 0, 
	"critical": 0, 
	"health": 0, 
	"speed": 0, 
	"luck": 0
}

func _ready() -> void:
	self.visible = false
	EventController.connect("level_up", on_event_level_up)
	EventController.connect("stats_progress", on_stats_progress)
	
func get_3_random_stats():
	var random_stat
	var icons = []
	for i in range(3):
		while true:
			random_stat = stats.keys()[randi() % stats.size()]
			if random_stat not in icons:
				break
		#stats[random_stat] = randi() % 10 + 1
		icons.append(random_stat)
		item_icons[i].texture = load(stats_icon_path + random_stat + ".png")
		
func on_event_level_up() -> void:
	get_tree().paused = true
	get_3_random_stats()
	self.visible = true
	
func on_stats_progress(stats) -> void:
	self.visible = false
