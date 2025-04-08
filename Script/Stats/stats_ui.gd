extends CanvasLayer

@onready var stats_icons: Array[TextureRect] = []
@onready var stats_rarities: Array[BBCodeRichTextLabel] = []
@onready var stats_values: Array[BBCodeRichTextLabel] = []
@onready var stats_backgrounds: Array[TextureRect] = []

@export var stats_icon_path: String = "res://Assets/Stats/icons/png180x/"
@export var stats_background_path: String = "res://Assets/Stats/Backgrounds/"
@export var stats_config_file_path: String = "res://Config/stats.cfg"

var stats_config: ConfigFile = ConfigFile.new()

var stats: Dictionary = {
	"damage": 0, 
	"attack_speed": 0.0, 
	"life_steal": 0, 
	"critical": 0, 
	"health_max": 0, 
	"speed": 0, 
	"luck": 0.0
}

var stats_modifier_impact_ranges: Dictionary = {
	"Malus": {
		"Annoying": 0,
		"Terrible": 40,
		"Malediction": 70,
		"Annihilation": 90
	},
	"Bonus": {
		"Common": 0,
		"Rare": 40,
		"Epic": 70,
		"Legendary": 90
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
		stats_backgrounds.append(get_node("Stat%d/StatFrame/StatBackground" % i))
		stats_icons.append(get_node("Stat%d/StatFrame/StatBackground/StatIcon" % i))
		stats_rarities.append(get_node("Stat%d/StatFrame/StatBackground/StatRarity" % i))
		stats_values.append(get_node("Stat%d/StatFrame/StatBackground/StatValue" % i))

func _ready() -> void:
	self.visible = false
	load_cfg_file()
	set_stat_nodes_lists()
	handle_events()

func load_cfg_file() -> void:
	var err = stats_config.load(stats_config_file_path)
	if err != OK:
		push_error("Impossible de charger le fichier de configuration: %s" % "res://Config/stats.cfg")
		return		

func biased_random_around_zero(bias: float = 0.0, max_value: int = 100) -> int:
	"""
	Generates a random number between -max_value and max_value.
	
	Parameters:
	- bias: controls the direction of the bias
		* bias = 0.0: symmetric distribution around 0
		* bias > 0: tendency towards positive numbers (the larger the bias, the closer to max_value)
		* bias < 0: tendency towards negative numbers (the smaller the bias, the closer to -max_value)
	
	The distribution favors numbers close to 0 in all cases.
	"""
	# Generate a number between 0 and 1
	var r: float = randf()
	
	# Apply a transformation to favor values close to 0
	# Use a bell-shaped distribution
	var value: float = pow(2 * r - 1, 3)  # Cube to keep the sign but tighten towards 0
	
	# Apply the bias (between -1 and 1)
	var biased_value: float = value + bias * (1 - abs(value)) * 0.1 # Reduce amplitude by multiplying by 0.1
	
	# Clamp between -1 and 1
	biased_value = clamp(biased_value, -1.0, 1.0)
	
	# Transform into a value between -max_value and max_value
	return int(biased_value * max_value)

func set_stat_icon(stat_icon: TextureRect, random_stat: String):
	stat_icon.texture = load(stats_icon_path + random_stat + ".png")

func get_stat_rarity(actual_value: int, max_value: int) -> String:
	"""
	Determines the rarity/impact level of a number based on its percentage of max_value.
	Handles both positive values (bonuses) and negative values (maluses).
	
	Parameters:
	- actual_value: The number to check
	- max_value: The maximum possible positive value
	
	Returns:
	- String indicating the rarity/impact level
	"""
	var absolute_value: Variant = abs(actual_value)
	if absolute_value > max_value:
		return "Legendary"
	
	var percentile = (float(absolute_value) / float(max_value)) * 100.0
	var category = "Bonus" if actual_value >= 0 else "Malus"
	var ranges = stats_modifier_impact_ranges[category]
	
	var sorted_rarities = [] # Sort thresholds in descending order
	for rarity in ranges:
		sorted_rarities.append({"name": rarity, "threshold": ranges[rarity]})
	sorted_rarities.sort_custom(func(a, b): return a["threshold"] > b["threshold"])
	
	for rarity_data in sorted_rarities:
		if percentile >= rarity_data["threshold"]:
			return rarity_data["name"]
	
	return "Unknown"

func set_stat_rarity(stat_rarity: BBCodeRichTextLabel, rarity: String):
	stat_rarity.set_bbcode_text(rarity)
	stat_rarity.set_font_color(stat_rarity_colors[rarity])

func get_stat_value_number(player_level: int, stat: String) -> Dictionary[String, Variant]:
	var stat_max_value: int = stats_config.get_value(stat, "max_value", 0)
	var stat_coefficent: Variant = stats_config.get_value(stat, "coefficent", 0)
	var stat_scaling: Variant = stats_config.get_value(stat, "scaling", 1)
	
	var random_stat_value: int = biased_random_around_zero(Global.luck, stat_max_value)
	while random_stat_value < 1 and random_stat_value > -1:
		random_stat_value = biased_random_around_zero(Global.luck, stat_max_value)

	var player_level_scaling: Variant = player_level * stat_scaling
	var stat_max_value_level: int = stat_max_value + player_level
	
	var final_stat_value: Variant = random_stat_value * stat_coefficent
	final_stat_value = final_stat_value + player_level_scaling if final_stat_value > 0 else final_stat_value - player_level_scaling
	return {"final_stat_value": final_stat_value, "stat_max_value_level": stat_max_value_level}

func set_stat_value(stat_value: BBCodeRichTextLabel, stat_value_number: Variant):
	var impact: String = "+" if stat_value_number > 0 else ""
	var stat_value_text = impact + str(stat_value_number)
	stat_value.set_bbcode_text(stat_value_text)
	
func set_stat_background(stat_background: TextureRect, rarity):
	var bg_color = stat_rarity_colors[rarity]
	stat_background.texture = load(stats_background_path + "STAT_BG_" + bg_color + ".png")
	
func set_3_random_stats(player_level: int):
	var icons = []
	for i in range(3):
		var random_stat: String
		while true:
			random_stat = stats.keys()[randi() % stats.size()]
			if random_stat not in icons:
				break
		icons.append(random_stat)
		random_stat = "luck"
		
		set_stat_icon(stats_icons[i], random_stat)
		var stat_values: Dictionary[String, Variant] = get_stat_value_number(player_level, random_stat)
		set_stat_value(stats_values[i], stat_values["final_stat_value"])
		var rarity: String = get_stat_rarity(stat_values["final_stat_value"], stat_values["stat_max_value_level"])
		set_stat_rarity(stats_rarities[i], rarity)
		set_stat_background(stats_backgrounds[i], rarity)
		
func on_event_level_up(player_level) -> void:
	get_tree().paused = true
	set_3_random_stats(player_level)
	self.visible = true

func on_stats_progress(_stats) -> void:
	self.visible = false
