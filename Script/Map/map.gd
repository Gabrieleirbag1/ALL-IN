extends Node2D

@export var slime_scene: PackedScene
@export var orc_scene: PackedScene
@export var xp_scene: PackedScene

var current_wave: int = 0
var enemies_alive: int = 0
var wave_spawn_ended: bool = false
var waves_settings = {
	1: {"mob_amount": 10, "mob_wait_time": 2.0},
	2: {"mob_amount": 20, "mob_wait_time": 1.5}
}

func _ready() -> void:
	EventController.connect("enemy_death", on_event_enemy_death)
	start_wave()

func start_wave():
	current_wave += 1
	Global.current_wave = current_wave
	print("Début de la vague %d" % current_wave)
	var settings = waves_settings.get(current_wave, {"mob_amount": 10, "mob_wait_time": 2.0})
	spawn_type("slime", settings.mob_amount, settings.mob_wait_time)

func on_event_enemy_death(xp: int, enemy_position: Vector2) -> void:
	enemies_alive -= 1
	drop_xp(xp, enemy_position)
	check_wave_end()

func check_wave_end():
	if wave_spawn_ended and enemies_alive == 0:
		print("Vague %d terminée !" % current_wave)
		if current_wave < waves_settings.size():
			start_wave()
		else:
			print("Toutes les vagues sont terminées !")

func spawn_type(type: String, mob_amount: int, mob_wait_time: float):
	wave_spawn_ended = false
	var slime_spawns = [$Spawn, $Spawn2, $Spawn3, $Spawn4]
	var total_spawned = 0
	
	while total_spawned < mob_amount:
		for spawn in slime_spawns:
			if total_spawned >= mob_amount:
				break
				
			var slime = orc_scene.instantiate()
			slime.global_position = spawn.global_position
			add_child(slime)
			enemies_alive += 1
			total_spawned += 1
			
		await get_tree().create_timer(mob_wait_time).timeout
	
	wave_spawn_ended = true
	check_wave_end()

func _process(delta: float) -> void:
	# print("Ennemis vivants: ", enemies_alive)
	# print("Vague en cours: ", current_wave)
	pass
	
func drop_xp(xp, enemy_position):
	var remaining_xp = xp
	var xp_types: Array = ["large", "medium", "small"]
	var xp_value: Dictionary = {"small": 1, "medium": 3, "large": 10}
	
	for xp_type in xp_types:
		while remaining_xp >= xp_value[xp_type]:
			var xp_instance = xp_scene.instantiate()
			var random_offset = Vector2(randi_range(-10, 10), randi_range(-10, 10))
			xp_instance.global_position = enemy_position + random_offset
			xp_instance.xp_type = xp_type
			add_child(xp_instance)
			remaining_xp -= xp_value[xp_type]
