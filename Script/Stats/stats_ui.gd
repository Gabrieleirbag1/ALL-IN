extends CanvasLayer

@onready var item_icons: Array[TextureRect] = []
@onready var stat_rarities: Array[CenteredRichTextLabel] = []
@onready var stat_values: Array[CenteredRichTextLabel] = []

@export var stats_icon_path: String = "res://Assets/Stats/icons/png180x/"

var stats: Dictionary = {
	"damage": 0, 
	"attack_speed": 0, 
	"life_steal": 0, 
	"critical": 0, 
	"health": 0, 
	"speed": 0, 
	"luck": 0
}

func handle_events():
	EventController.connect("level_up", on_event_level_up)
	EventController.connect("stats_progress", on_stats_progress)

func set_stat_nodes_lists():
	for i in range(1, 4):
		item_icons.append(get_node("Stat%d/StatFrame/TextureRect/ItemIcon" % i))
		stat_rarities.append(get_node("Stat%d/StatFrame/TextureRect/StatRarity" % i))
		stat_values.append(get_node("Stat%d/StatFrame/TextureRect/StatValue" % i))

func _ready() -> void:
	self.visible = false
	set_stat_nodes_lists()
	handle_events()
	
func set_3_random_stats():
	var icons = []
	for i in range(3):
		var random_stat
		while true:
			random_stat = stats.keys()[randi() % stats.size()]
			if random_stat not in icons:
				break
		icons.append(random_stat)
		var rarity = "Common"
		var impact = "+ "
		item_icons[i].texture = load(stats_icon_path + random_stat + ".png")
		stat_rarities[i].set_centered_text(rarity)
		stat_values[i].set_centered_text(impact + str(randi() % 10 + 1))
	
func on_event_level_up() -> void:
	get_tree().paused = true
	set_3_random_stats()
	self.visible = true

func on_stats_progress(stats) -> void:
	self.visible = false
