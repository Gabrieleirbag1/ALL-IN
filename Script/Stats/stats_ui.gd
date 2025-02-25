extends CanvasLayer

@onready var stat_icons: Array[TextureRect] = []
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

var impact: Dictionary = {
	"Malus": {
		"Annihilation": [-INF, -10],
		"Malediction": [-9, -7],
		"Terrible": [-6, -4],
		"Annoying": [-3, -1]
	},
	"Bonus": {
		"Common": [1, 3],
		"Rare": [4-6],
		"Epic": [7-9],
		"Legendary": [10, INF]
	}
}

func handle_events():
	EventController.connect("level_up", on_event_level_up)
	EventController.connect("stats_progress", on_stats_progress)

func set_stat_nodes_lists():
	for i in range(1, 4):
		stat_icons.append(get_node("Stat%d/StatFrame/TextureRect/StatIcon" % i))
		stat_rarities.append(get_node("Stat%d/StatFrame/TextureRect/StatRarity" % i))
		stat_values.append(get_node("Stat%d/StatFrame/TextureRect/StatValue" % i))

func _ready() -> void:
	self.visible = false
	set_stat_nodes_lists()
	handle_events()
	
func set_stat_icon(stat_icon: TextureRect, random_stat: String):
	stat_icon.texture = load(stats_icon_path + random_stat + ".png")

func get_stat_rarity():
	pass

func set_stat_rarity(stat_rarity: CenteredRichTextLabel, rarity: String):
	stat_rarity.set_centered_text(rarity)

func get_stat_value_text() -> String:
	var random_value: int = randi() % 10 + 1
	var impact: String = "+ "
	return impact + str(random_value)

func set_stat_value(stat_value: CenteredRichTextLabel, stat_value_text: String):
	stat_value.set_centered_text(stat_value_text)

func set_3_random_stats():
	var icons = []
	for i in range(3):
		var random_stat: String
		while true:
			random_stat = stats.keys()[randi() % stats.size()]
			print(random_stat)
			if random_stat not in icons:
				break
		icons.append(random_stat)
		set_stat_icon(stat_icons[i], random_stat)
		var stat_value_text: String = get_stat_value_text()
		set_stat_value(stat_values[i], stat_value_text)
		get_stat_rarity()
		set_stat_rarity(stat_rarities[i], "Common")
		
func on_event_level_up() -> void:
	get_tree().paused = true
	set_3_random_stats()
	self.visible = true

func on_stats_progress(stats) -> void:
	self.visible = false
