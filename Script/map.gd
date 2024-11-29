extends Node2D

<<<<<<< HEAD


var current_wave : int
@export var skeleton_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
=======
# Variables pour la gestion des vagues et du spawn
@export var skeleton_scene: PackedScene = preload("/Users/mahefradin/Desktop/Survivor-Godot/Scene/enemies.tscn")

var current_wave: int = 0
var starting_nodes: int = 5  # Nombre de squelettes à spawner par vague
var current_nodes: int = 0  # Nombre de squelettes actuellement actifs
var wave_spawn_ended: bool = false

# Points de spawn
var spawn_points: Array = []

func _ready() -> void:
	# Charger les points de spawn
	_load_spawn_points()

	# Initialiser la première vague
	_spawn_wave()

func _load_spawn_points() -> void:
	# Chercher tous les Marker2D enfants dont le nom commence par "spawn"
	for i in range(1, 6):  # Les noms des spawns vont de spawn1 à spawn5
		var spawn_name = "Spawn" + str(i)
		var spawn_point = $Spawn1
		if spawn_point and spawn_point is Marker2D:
			spawn_points.append(spawn_point)

	if spawn_points.size() == 0:
		print("Aucun point de spawn trouvé. Vérifiez que les Marker2D sont correctement nommés.")

func _spawn_wave() -> void:
	# Réinitialise les compteurs
	current_nodes = 0
	wave_spawn_ended = false

	if spawn_points.size() == 0:
		print("Impossible de spawner. Aucun point de spawn disponible.")
		return

	for i in range(starting_nodes):
		_spawn_skeleton()

	# Marque la fin du spawn pour cette vague
	wave_spawn_ended = true

func _spawn_skeleton() -> void:
	# Instancier un squelette si la scène est définie
	if not skeleton_scene:
		print("Erreur : La scène skeleton_scene n'est pas assignée.")
		return

	if spawn_points.size() == 0:
		print("Erreur : Aucun point de spawn n'est défini.")
		return

	# Choisir un point de spawn aléatoire
	var random_spawn_point = spawn_points[randi() % spawn_points.size()]
	var skeleton_instance = skeleton_scene

	# Positionner le squelette sur le point de spawn
	skeleton_instance.position = random_spawn_point.position

	# Ajouter le squelette comme enfant de la scène
	add_child(skeleton_instance)

	# Mettre à jour le compteur de squelettes
	current_nodes += 1
 
func _process(delta: float) -> void:
	# Exemple : si tous les squelettes d'une vague sont détruits, passer à la vague suivante
	if wave_spawn_ended and current_nodes == 0:
		current_wave += 1
		print("Début de la vague ", current_wave)
		_spawn_wave()
>>>>>>> 5dec3fc (spawning)
