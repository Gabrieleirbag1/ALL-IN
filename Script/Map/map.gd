extends Node2D

@export var slime_scene: PackedScene
@export var orc_scene: PackedScene
@export var xp_scene: PackedScene
@export var waves_file: String = Global.config_dir_path + "/waves.json"
@export var orc_rider: PackedScene

@onready var background_music : Node = $Background_Music

var enemies_alive: int = 0
var enemy_properties: Dictionary = {}
var score = 0

func _ready() -> void:
	background_music.playing = true
	set_enemy_properties()
	load_waves_config()
	EventController.connect("enemy_death", Callable(self, "on_event_enemy_death"))
	
func set_enemy_properties() -> void:
	enemy_properties = {
		"slime": {
			"scene": slime_scene,
			"score": 1
		},
		"orc": {
			"scene": orc_scene,
			"score": 5
		},
		"orc_rider": {
			"scene": orc_rider,
			"score": 8
		}
	}

func load_waves_config() -> void:
	var file = FileAccess.open(waves_file, FileAccess.READ)
	if file == null:
		push_error("Impossible d'ouvrir le fichier de test des vagues: %s" % waves_file)
		return
	var data = file.get_as_text()
	var json = JSON.parse_string(data)

	for wave_data in json.waves:
		start_wave(wave_data)

func set_enemy_properties_score(enemies) -> void:
	for enemy in enemies:
		enemy_properties[enemy.enemy_type]["score"] = enemy.score

func calculate_best_spawn_points(affected_spawn_points_number: int) -> Array[Node]:
	var spawn_points: Array[Node] = [$Spawn, $Spawn2]
	return spawn_points
	
func chose_random_enemy(enemies: Array) -> String:
	var rand = randi() % 100
	var cumulative_percentage = 0.0
	for enemy_data in enemies:
		cumulative_percentage += enemy_data.spawn_percentage * 100
		if rand < cumulative_percentage:
			return enemy_data.enemy_type
	return enemies[0].enemy_type  # Fallback

func spawn_mob(enemies, spawn):
	var enemy_type = chose_random_enemy(enemies)
	var enemy_data = enemy_properties.get(enemy_type, null)
	if enemy_data:
		var enemy = enemy_data["scene"].instantiate()
		enemy.global_position = spawn.global_position
		add_child(enemy)

func start_wave(wave_data: Dictionary) -> void:
	var wave_num = wave_data.get("wave_number", 1)
	var affected_spawn_points_number = wave_data.get("affected_spawn_points_number", 4)
	var score_to_reach = wave_data.get("score_to_reach", 2.0)
	var enemies: Array = wave_data.get("enemies", [{}])

	set_enemy_properties_score(enemies)
	
	var spawn_points: Array[Node] = calculate_best_spawn_points(affected_spawn_points_number)
	var wait_time = wave_data.get("spawn_interval", 1.0)
	
	while score < score_to_reach:
		for spawn in spawn_points:
			spawn_mob(enemies, spawn)
			await get_tree().create_timer(wait_time).timeout
	score = 0

func on_event_enemy_death(xp: int, enemy_position: Vector2, _enemy_type) -> void:
	enemies_alive -= 1
	drop_xp(xp, enemy_position)
	score += enemy_properties[_enemy_type]["score"]

func drop_xp(xp: int, enemy_position: Vector2) -> void:
	var remaining_xp = xp
	var xp_types: Array = ["large", "medium", "small"]
	var xp_value: Dictionary = {"small": 1, "medium": 3, "large": 10}
	
	for xp_type in xp_types:
		while remaining_xp >= xp_value[xp_type]:
			var xp_instance = xp_scene.instantiate()
			xp_instance.global_position = enemy_position
			xp_instance.xp_type = xp_type
			add_child(xp_instance)
			remaining_xp -= xp_value[xp_type]
