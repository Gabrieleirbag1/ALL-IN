extends Node2D

@export var slime_scene: PackedScene
@export var xp_scene: PackedScene

var current_wave: int = 0
var starting_nodes: int = 5 
var current_nodes: int = 0  
var wave_spawn_ended: bool = false

func _ready() -> void:
	EventController.connect("enemy_death", on_event_enemy_death)
	current_wave = 0
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()

func on_event_enemy_death(xp: int, enemy_position: Vector2) -> void:
	drop_xp(xp, enemy_position)

func drop_xp(xp, enemy_position):
	var remaining_xp = xp
	var xp_types = ["large", "medium", "small"]
	var xp_value: Dictionary = {"small": 100, "medium": 200, "large": 500}
	
	for xp_type in xp_types:
		while remaining_xp >= xp_value[xp_type]:
			var xp_instance = xp_scene.instantiate()
			var random_offset = Vector2(randi_range(-10, 10), randi_range(-10, 10))
			xp_instance.global_position = enemy_position + random_offset
			xp_instance.xp_type = xp_type
			add_child(xp_instance)
			remaining_xp -= xp_value[xp_type]

func position_to_next_wave():
	if current_nodes == starting_nodes:
		if current_wave != 0:
			Global.moving_to_next_wave = true
		current_wave +=1
		Global.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepapre_spawn("slime", 4.0, 4.0) #type, multiplier, spawns

func prepapre_spawn(type, multiplier, mob_spawns):
	var mob_amount = 50 # Fixé à 50 slimes pour cette vague
	var mob_wait_time: float = 2.0
	var mob_spawn_rounds = mob_amount / mob_spawns
	spawn_type(type, mob_spawn_rounds, mob_wait_time)
	
func spawn_type(type, mob_spawn_rounds, mob_wait_time):
	if type == "slime":
		var slime_spawn1 = $Spawn
		var slime_spawn2 = $Spawn2
		var slime_spawn3 = $Spawn3
		var slime_spawn4 = $Spawn4
		var total_spawned = 0  # Nombre total de slimes générés
		
		while mob_spawn_rounds > 0 and total_spawned < 50:  # Limite à 50 slimes
			var slime1 = slime_scene.instantiate()
			slime1.global_position = slime_spawn1.global_position
			var slime2 = slime_scene.instantiate()
			slime2.global_position = slime_spawn2.global_position
			var slime3 = slime_scene.instantiate()
			slime3.global_position = slime_spawn3.global_position
			var slime4 = slime_scene.instantiate()
			slime4.global_position = slime_spawn4.global_position
			
			add_child(slime1)
			add_child(slime2)
			add_child(slime3)
			add_child(slime4)
			
			total_spawned += 4  # Ajoute 4 slimes
			mob_spawn_rounds -= 1
			await get_tree().create_timer(mob_wait_time).timeout
		
		wave_spawn_ended = true

				
func _process(delta: float) -> void:
	pass
	
