extends CanvasLayer

@onready var stat_icons: Array[TextureRect] = []
@onready var stat_rarities: Array[CenteredRichTextLabel] = []
@onready var stat_values: Array[CenteredRichTextLabel] = []
@onready var stat_backgrounds: Array[TextureRect] = []

@export var stat_icon_path: String = "res://Assets/Stats/icons/png180x/"
@export var stat_background_path: String = "res://Assets/Stats/Backgrounds/"

var stats: Dictionary = {
	"damage": 0, 
	"attack_speed": 0, 
	"life_steal": 0, 
	"critical": 0, 
	"health": 0, 
	"speed": 0, 
	"luck": 0
}

var stat_modifier_impact_ranges: Dictionary = {
	"Malus": {
		"Annihilation": [-INF, -10],
		"Malediction": [-9, -7],
		"Terrible": [-6, -4],
		"Annoying": [-3, -1]
	},
	"Bonus": {
		"Common": [1, 3],
		"Rare": [4, 6],
		"Epic": [7, 9],
		"Legendary": [10, INF]
	}
}
var stat_rarity_colors: Dictionary = {
	"Annihilation": "RED",
	"Malediction": "INDIGO",
	"Terrible": "CADET_BLUE",
	"Annoying": "YELLOW_GREEN",
	"Common": "FOREST_GREEN",
	"Rare": "BLUE",
	"Epic": "PURPLE",
	"Legendary": "GOLD"
}

func handle_events():
	EventController.connect("level_up", on_event_level_up)
	EventController.connect("stats_progress", on_stats_progress)

func set_stat_nodes_lists():
	for i in range(1, 4):
		stat_backgrounds.append(get_node("Stat%d/StatFrame/StatBackground" % i))
		stat_icons.append(get_node("Stat%d/StatFrame/StatBackground/StatIcon" % i))
		stat_rarities.append(get_node("Stat%d/StatFrame/StatBackground/StatRarity" % i))
		stat_values.append(get_node("Stat%d/StatFrame/StatBackground/StatValue" % i))

func _ready() -> void:
	self.visible = false
	set_stat_nodes_lists()
	handle_events()
	
func set_stat_icon(stat_icon: TextureRect, random_stat: String):
	stat_icon.texture = load(stat_icon_path + random_stat + ".png")

func get_stat_rarity(stat_value_number: int) -> String:
	var modifier = "Bonus" if stat_value_number > 0 else "Malus"
	for rarity in stat_modifier_impact_ranges[modifier]:
		var rarity_range = stat_modifier_impact_ranges[modifier][rarity]
		if stat_value_number >= rarity_range[0] and stat_value_number <= rarity_range[1]:
			return rarity
	return "Unknown"

func set_stat_rarity(stat_rarity: CenteredRichTextLabel, rarity: String):
	stat_rarity.set_centered_text(rarity)
	stat_rarity.set_font_color(stat_rarity_colors[rarity])

func get_stat_value_number(player_level) -> int:
	var pos_min: int
	var pos_max: int

	# For level 1, use fixed bounds.
	if player_level == 1:
		pos_min = 1
		pos_max = 10
	else:
		# For other levels, bounds increase.
		# Positive range: [10*(level-1), ...]
		pos_min = 10 * (player_level - 1)
		if player_level == 2:
			pos_max = 10 * player_level
		else:
			# Level 3: [20, 35], level 4: [30, 50], etc.
			pos_max = pos_min + 10 + (player_level - 2) * 5

	# Randomly decide to return a positive or negative value.
	# If positive, value between pos_min and pos_max.
	# If negative, value between -pos_max and -pos_min.
	var rand_val = randi_range(pos_min, pos_max)
	if randf() < 0.5:
		return rand_val
	else:
		return -rand_val

func set_stat_value(stat_value: CenteredRichTextLabel, stat_value_number: int):
	var impact: String = "+" if stat_value_number > 0 else ""
	var stat_value_text = impact + str(stat_value_number)
	stat_value.set_centered_text(stat_value_text)
	
func set_stat_background(stat_background: TextureRect, rarity):
	var bg_color = stat_rarity_colors[rarity]
	stat_background.texture = load(stat_background_path + "STAT_BG_" + bg_color + ".png")
	
func set_3_random_stats(player_level: int):
	var icons = []
	for i in range(3):
		var random_stat: String
		while true:
			random_stat = stats.keys()[randi() % stats.size()]
			if random_stat not in icons:
				break
		icons.append(random_stat)
		
		set_stat_icon(stat_icons[i], random_stat)
		var stat_value_number: int = get_stat_value_number(player_level)
		set_stat_value(stat_values[i], stat_value_number)
		var rarity = get_stat_rarity(stat_value_number)
		set_stat_rarity(stat_rarities[i], rarity)
		set_stat_background(stat_backgrounds[i], rarity)
		
func on_event_level_up(player_level) -> void:
	get_tree().paused = true
	set_3_random_stats(player_level)
	self.visible = true

func on_stats_progress(_stats) -> void:
	self.visible = false
