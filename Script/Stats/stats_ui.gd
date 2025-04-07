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
		"Annihilation": [-INF, -9],
		"Malediction": [-9, -6],
		"Terrible": [-6, -3],
		"Annoying": [-3, -1]
	},
	"Bonus": {
		"Common": [1, 3],
		"Rare": [3, 6],
		"Epic": [6, 9],
		"Legendary": [9, INF]
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
	Génère un nombre aléatoire entre -max_value et max_value.
	
	Paramètres:
	- bias: contrôle la direction du biais
		* bias = 0.0: distribution symétrique autour de 0
		* bias > 0: tendance vers les nombres positifs (plus bias est grand, plus ça tend vers max_value)
		* bias < 0: tendance vers les nombres négatifs (plus bias est petit, plus ça tend vers -max_value)
	
	La distribution favorise les nombres proches de 0 dans tous les cas.
	"""
	# Générer un nombre entre 0 et 1
	var r: float = randf()
	
	# Appliquer une transformation pour favoriser les valeurs proches de 0
	# Utiliser une distribution en forme de cloche
	var value: float = pow(2 * r - 1, 3)  # Cube pour garder le signe mais resserrer vers 0
	
	# Appliquer le biais (entre -1 et 1)
	var biased_value: float = value + bias * (1 - abs(value)) * 0.1
	
	# Limiter entre -1 et 1
	biased_value = clamp(biased_value, -1.0, 1.0)
	
	# Transformer en valeur entre -max_value et max_value
	return int(biased_value * max_value)

func set_stat_icon(stat_icon: TextureRect, random_stat: String):
	stat_icon.texture = load(stats_icon_path + random_stat + ".png")

func get_stat_rarity(stat_value_number: Variant) -> String:
	var modifier = "Bonus" if stat_value_number > 0 else "Malus"
	for rarity in stats_modifier_impact_ranges[modifier]:
		var rarity_range = stats_modifier_impact_ranges[modifier][rarity]
		if stat_value_number >= rarity_range[0] and stat_value_number <= rarity_range[1]:
			return rarity
	return "Unknown"

func set_stat_rarity(stat_rarity: BBCodeRichTextLabel, rarity: String):
	stat_rarity.set_bbcode_text(rarity)
	stat_rarity.set_font_color(stat_rarity_colors[rarity])

func get_stat_value_number(player_level: int, stat: String) -> Variant:
	var stat_max_value: int = stats_config.get_value(stat, "max_value", 0)
	var stat_coefficent: Variant = stats_config.get_value(stat, "coefficent", 0)
	var random_stat_value: int = biased_random_around_zero(0.0, stat_max_value)
	var final_stat_value = random_stat_value * stat_coefficent + player_level
	return final_stat_value

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
		
		set_stat_icon(stats_icons[i], random_stat)
		var stat_value_number: Variant = get_stat_value_number(player_level, random_stat)
		set_stat_value(stats_values[i], stat_value_number)
		var rarity: String = get_stat_rarity(stat_value_number)
		set_stat_rarity(stats_rarities[i], rarity)
		set_stat_background(stats_backgrounds[i], rarity)
		
func on_event_level_up(player_level) -> void:
	get_tree().paused = true
	set_3_random_stats(player_level)
	self.visible = true

func on_stats_progress(_stats) -> void:
	self.visible = false
