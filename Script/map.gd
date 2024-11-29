extends Node2D



var current_wave : int
@export var skeleton_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
# Variables pour la gestion des vagues et du spawn
@export var skeleton_scene: PackedScene = preload("/Users/mahefradin/Desktop/Survivor-Godot/Scene/enemies.tscn")

var current_wave: int = 0
var starting_nodes: int = 5  # Nombre de squelettes à spawner par vague
var current_nodes: int = 0  # Nombre de squelettes actuellement actifs
var wave_spawn_ended: bool = false

# Points de spawn
var spawn_points: Array = []

func _ready() -> void:
	SceneTransitionAnimation.play("between_wave")
	current_wave = 0
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()
	
func position_to_next_wave():
	if current_nodes == starting_nodes:
		if current_wave != 0:
			Global.moving_to_next_wave = true
			
		SceneTransitionAnimation.play("between_wave")
		current_wave +=1
		Global.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepapre_spawn("skeleton", 4.0, 4.0)
		print(current_wave)


func prepapre_spawn(type, multiplier, mob_spawns):
	var mob_amout = float(current_wave) * multiplier
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Exemple : si tous les squelettes d'une vague sont détruits, passer à la vague suivante
	if wave_spawn_ended and current_nodes == 0:
		current_wave += 1
		print("Début de la vague ", current_wave)
		_spawn_wave()
