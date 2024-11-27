extends Node2D

@export var spawn_interval: float = 2.0
@export var spawn_margin: float = 100
@export var max_enemies: float = 10
@export var enemy_scene = preload("res://Scene/enemies.tscn")


# Liste des ennemis actifs
var active_enemies = []

# Références au joueur et à la caméra
@onready var player = null
@onready var camera = null

func _ready() -> void:
	# Récupérer les références du joueur et de la caméra
	player = get_node("/root/Map/Player")  # Ajuste le chemin selon ton projet
	camera = get_node("/root/Map/Camera2D")  # Ajuste le chemin selon ton projet

	# Vérifie que la scène d'ennemi est assignée
	if not enemy_scene:
		print("Erreur : Aucune scène 'enemy_scene' assignée !")
		return

	# Crée et configure un Timer pour le spawn
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.connect("timeout", self, "_spawn_enemy")
	add_child(timer)
	timer.start()

func _spawn_enemy() -> void:
	# Ne pas spawner si le nombre max d'ennemis est atteint
	if active_enemies.size() >= max_enemies:
		return

	# Calcule une position hors de la caméra
	var spawn_position = _get_spawn_position()
	
	# Instancie un nouvel ennemi
	var enemy = enemy_scene.instance()
	enemy.position = spawn_position
	add_child(enemy)

	# Ajoute à la liste des ennemis actifs
	active_enemies.append(enemy)

	# Connecte le signal pour retirer l'ennemi lorsqu'il quitte la scène
	enemy.connect("tree_exited", self, "_on_enemy_removed", [enemy])

	# Oriente l'ennemi vers le joueur (optionnel)
	if player:
		enemy.look_at(player.global_position)

func _get_spawn_position() -> Vector2:
	# Récupère les limites de la caméra
	if not camera:
		return Vector2.ZERO

	var viewport_rect = camera.get_visible_rect()
	
	# Calcule une position aléatoire hors de la caméra
	var x_outside = viewport_rect.position.x + randf_range(-spawn_margin, viewport_rect.size.x + spawn_margin * 2)
	var y_outside = viewport_rect.position.y + randf_range(-spawn_margin, viewport_rect.size.y + spawn_margin * 2)

	# S'assurer que l'ennemi spawn bien en dehors des limites visibles
	if x_outside > viewport_rect.position.x and x_outside < viewport_rect.position.x + viewport_rect.size.x:
		x_outside += sign(x_outside) * spawn_margin
	if y_outside > viewport_rect.position.y and y_outside < viewport_rect.position.y + viewport_rect.size.y:
		y_outside += sign(y_outside) * spawn_margin

	return Vector2(x_outside, y_outside)

func _on_enemy_removed(enemy) -> void:
	# Supprime l'ennemi de la liste des actifs lorsqu'il est retiré de la scène
	active_enemies.erase(enemy)
