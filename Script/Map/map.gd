extends Node2D

@export var slime_scene: PackedScene
@export var orc_scene: PackedScene
@export var xp_scene: PackedScene
@export var waves_file: String = Global.config_dir_path + "/waves.json"
@export var orc_rider: PackedScene

@onready var background_music : Node = $Background_Music

var enemies_alive: int = 0
var max_enemies_on_screen: int = 100
var enemy_properties: Dictionary = {}
var score = 0
var enemy_pool: Array = []

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
	
func sort_middle_short_far(a: Node, b: Node) -> bool:
	#sort the distances to have the middle range distances first, then short, then far
	var screen_size = get_viewport_rect().size
	print(screen_size)
	var middle_distance = screen_size.length() / 2
	print(middle_distance)
	var distance_spawn_player = a.global_position.distance_to(Global.player.global_position)
	var a_diff = abs(distance_spawn_player - middle_distance)
	var distance_spawn_player_b = b.global_position.distance_to(Global.player.global_position)
	var b_diff = abs(distance_spawn_player_b - middle_distance)
	print(a_diff, " ",b_diff)
	return a_diff < b_diff
	
func sort_asending_outside_viewport_descending(a: Node, b: Node) -> bool:
	var screen_size = get_viewport_rect().size
	# the farest position from the viewport center, like the left top corner or right bottom corner
	var farest_position_viewport = Vector2(678, 131)
	print("Farest position: ", farest_position_viewport)
	var distance = farest_position_viewport.distance_to(Global.player.global_position)
	var distance_spawn_player = a.global_position.distance_to(Global.player.global_position)
	var a_diff = distance_spawn_player - distance
	print(a_diff)
	var distance_spawn_player_b = b.global_position.distance_to(Global.player.global_position)
	var b_diff = distance_spawn_player_b - distance
	print(b_diff)
	
	if (a_diff > 0 and b_diff > 0):
		return a_diff < b_diff
	else:
		return a_diff > b_diff

func select_best_spawn_points(affected_spawn_points_number: int) -> Array[Node]:
	var spawn_points: Array[Node] = [$Spawn, $Spawn2, $Spawn3, $Spawn4, $Spawn5]
	spawn_points.sort_custom(sort_asending_outside_viewport_descending)
	print(spawn_points)
	var selected_spawn_points: Array[Node] = []
	for i in range(affected_spawn_points_number):
		selected_spawn_points.append(spawn_points[i])
	return selected_spawn_points
	
func chose_random_enemy(enemies: Array) -> String:
	var rand = randi() % 100
	var cumulative_percentage = 0.0
	for enemy_data in enemies:
		cumulative_percentage += enemy_data.spawn_percentage * 100
		if rand < cumulative_percentage:
			return enemy_data.enemy_type
	return enemies[0].enemy_type  # Fallback

func setup_enemy(enemy_type: String) -> Enemy:
	var enemy_data = enemy_properties.get(enemy_type, null)
	if enemy_data:
		var enemy_instance: Enemy = enemy_data["scene"].instantiate()
		enemy_instance.handle_states(false)
		enemy_pool.append(enemy_instance)
		add_child(enemy_instance)
		return enemy_instance
	return null

func set_enemy_pool(enemies: Array) -> void:
	enemy_pool.clear()
	var pool_size = 50
	for i in range(pool_size):
		var enemy_type = chose_random_enemy(enemies)
		setup_enemy(enemy_type)

func extend_pool(enemy_type: String) -> Enemy:
	var enemy_instance = setup_enemy(enemy_type)
	print("Extended pool with enemy: %s" % enemy_type)
	return enemy_instance

func get_pooled_enemy(enemy_type: String) -> Enemy:
	for enemy in enemy_pool:
		if not enemy.visible and enemy.enemy_type.begins_with(enemy_type):
			return enemy
	return extend_pool(enemy_type)

func spawn_mob(enemies, spawn):
	if enemies_alive >= max_enemies_on_screen:
		return
	var enemy_type = chose_random_enemy(enemies)
	var enemy_scene = enemy_properties.get(enemy_type, null)
	if enemy_scene:
		var enemy: Enemy = get_pooled_enemy(enemy_type)
		if enemy:
			enemy.global_position = spawn.global_position
			enemy.revive()
			enemies_alive += 1

func start_wave(wave_data: Dictionary) -> void:
	var wave_num = wave_data.get("wave_number", 1)
	var affected_spawn_points_number = wave_data.get("affected_spawn_points_number", 4)
	var score_to_reach = wave_data.get("score_to_reach", 2.0)
	var enemies: Array = wave_data.get("enemies", [{}])

	set_enemy_properties_score(enemies)
	set_enemy_pool(enemies)
	
	var spawn_points: Array[Node] = select_best_spawn_points(affected_spawn_points_number)
	print(spawn_points)
	var wait_time = wave_data.get("spawn_interval", 1.0)
	
	while score < score_to_reach:
		for spawn in spawn_points:
			spawn_mob(enemies, spawn)
			await get_tree().create_timer(wait_time).timeout
	score = 0

func on_event_enemy_death(xp: int, enemy_position: Vector2, enemy_type: String) -> void:
	enemies_alive -= 1
	drop_xp(xp, enemy_position)
	var enemy_score = enemy_properties[enemy_type]["score"]
	score += enemy_score

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
