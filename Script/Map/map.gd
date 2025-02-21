extends Node2D

@export var slime_scene: PackedScene
@export var orc_scene: PackedScene
@export var xp_scene: PackedScene
@export var waves_file: String = "res://Script/Global/waves.cfg"
@export var orc_rider: PackedScene

@onready var background_music : Node = $Background_Music

var current_wave: int = 0
var enemies_alive: int = 0
var wave_active: bool = false  
var waves_settings: Dictionary = {}
var enemy_scenes: Dictionary = {}
var wave_spawn_complete: Dictionary = {}



func _ready() -> void:
	background_music.playing = true
	enemy_scenes = {
		"slime": slime_scene,
		"orc": orc_scene,
		"orc_rider": orc_rider
	}
	load_waves_config()
	EventController.connect("enemy_death", Callable(self, "on_event_enemy_death"))
	start_wave()

func load_waves_config() -> void:
	var config = ConfigFile.new()
	var err = config.load(waves_file)
	if err != OK:
		push_error("Impossible de charger le fichier de configuration: %s" % waves_file)
		return
	for section in config.get_sections():
		if section.begins_with("wave"):
			var wave_num = int(section.replace("wave", ""))
			# mob_wait_time correspond au temps d'attente entre chaque batch d'instanciation
			var mob_wait_time = config.get_value(section, "mob_wait_time", 2.0)
			var enemies = {}
			# Pour chaque clé de la section (autre que mob_wait_time), on récupère le nombre d'ennemis attendu
			for key in config.get_section_keys(section):
				if key != "mob_wait_time":
					enemies[key] = config.get_value(section, key, 0)
			waves_settings[wave_num] = {"mob_wait_time": mob_wait_time, "enemies": enemies}

func start_wave() -> void:
	if wave_active:
		return
	wave_active = true
	current_wave += 1
	Global.current_wave = current_wave
	print("Début de la vague %d" % current_wave)
	var settings = waves_settings.get(current_wave, {"mob_wait_time": 2.0, "enemies": {}})
	spawn_wave(settings)

func on_event_enemy_death(xp: int, enemy_position: Vector2, enemy_type) -> void:
	enemies_alive -= 1
	drop_xp(xp, enemy_position)
	check_wave_end()

func check_wave_end() -> void:
	# On considère que le spawn est terminé si, pour chaque type d'ennemi, le spawn est complet
	var spawning_complete = true
	for enemy_type in wave_spawn_complete.keys():
		if wave_spawn_complete[enemy_type] == false:
			spawning_complete = false
			break
	if spawning_complete and enemies_alive == 0:
		print("Vague %d terminée !" % current_wave)
		wave_active = false
		# Réinitialisation pour la prochaine vague
		wave_spawn_complete.clear()
		if waves_settings.has(current_wave + 1):
			start_wave()
		else:
			print("Toutes les vagues sont terminées !")

func spawn_wave(settings: Dictionary) -> void:
	wave_spawn_complete.clear()
	var enemies_config: Dictionary = settings.get("enemies", {})
	var mob_wait_time: float = settings.get("mob_wait_time", 2.0)
	# Pour chaque type d'ennemi prévu dans la vague...
	for enemy_type in enemies_config.keys():
		var count: int = enemies_config[enemy_type]
		if count > 0:
			wave_spawn_complete[enemy_type] = false
			spawn_type(enemy_type, count, mob_wait_time)
	# On ne marque pas la vague comme terminée ici, cela se fera dans spawn_next quand chaque type aura terminé

func spawn_type(enemy_type: String, mob_amount: int, mob_wait_time: float) -> void:
	var spawn_points = [$Spawn, $Spawn2, $Spawn, $Spawn4]  # Assurez-vous que ces noeuds existent dans la scène
	spawn_next(enemy_type, mob_amount, mob_wait_time, spawn_points, 0)

func spawn_next(enemy_type: String, mob_amount: int, mob_wait_time: float, spawn_points: Array, total_spawned: int) -> void:
	# Pour chaque point de spawn, on instancie un ennemi jusqu'à atteindre le nombre requis
	for spawn in spawn_points:
		if total_spawned >= mob_amount:
			break
		var enemy_scene = enemy_scenes.get(enemy_type, null)
		if enemy_scene:
			var enemy = enemy_scene.instantiate()
			enemy.global_position = spawn.global_position
			add_child(enemy)
			enemies_alive += 1
			total_spawned += 1

	if total_spawned < mob_amount:
		var timer = Timer.new()
		timer.wait_time = mob_wait_time
		timer.one_shot = true
		add_child(timer)
		timer.start()
		timer.timeout.connect(Callable(self, "spawn_next").bind(enemy_type, mob_amount, mob_wait_time, spawn_points, total_spawned))
	else:
		# Fin du spawn pour ce type d'ennemi
		wave_spawn_complete[enemy_type] = true
		check_wave_end()

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

func _process(delta: float) -> void:
	pass
