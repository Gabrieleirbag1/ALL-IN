class_name Player extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@onready var invincibility_timer: Timer = $Invincibility
@onready var hurted_timer: Timer = $Hurted
@onready var zoom_timer: Timer = $Zoom
@onready var texture_rect: TextureRect = $Level/Control/TextureRect
@onready var level_label: Label = $Level/Control/Level_label
@onready var camera: Camera2D = $Camera2D
@onready var game_over = $GameOver
@onready var death_sound = $Death_Sound
@onready var hurt_sound = $Hurt_Sound
@onready var fireball_sound = $Fireball_sound
@onready var hud_texture_rect: TextureRect = $"../HUD/HUDTextureRect"
@onready var attack_cooldown_timer: Timer = Timer.new()

const fireball_scene: PackedScene = preload("res://Scene/Projectiles/FireBall.tscn")
@onready var spawn_projectile_right: Marker2D = $SpawnProjectileRight
@onready var spawn_projectile_left: Marker2D = $SpawnProjectileLeft
@onready var spawn_projectile_up: Marker2D = $SpawnProjectileUp
@onready var spawn_projectile_down: Marker2D = $SpawnProjectileDown

@export_file("*.cfg") var stats_config_file_path: String = Global.config_dir_path + "/stats.cfg"
var stats_config: ConfigFile = ConfigFile.new()
		
var stats: Dictionary = {
	"damage": Global.player_damage,
	"attack_speed": 1,
	"life_steal": 0,
	"critical": Global.player_critical,
	"health": 50,
	"health_max": 50,
	"health_min": 0,
	"speed": 250,
	"experience": 0,
	"luck": Global.luck
}

var has_spawned_fireball: bool = false
var level: int = 1
var alive : bool = true
var death_animation_played : bool = false
var immortal: bool = false
var invincible: bool = false
var is_attacking: bool = false
var can_attack: bool = true

func _ready() -> void:
	Global.load_cfg_file(stats_config, stats_config_file_path)

	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timeout)
	add_child(attack_cooldown_timer)
	
	handle_new_stats(stats, false)
	level = MathXp.calculate_level_from_exp(stats["experience"])
	level_label.text = str(level)
	handle_signals()
	
func handle_signals():
	EventController.connect("xp_collected", on_event_xp_collected)
	EventController.connect("stats_progress", on_event_stats_progress)
	EventController.connect("projectile_throw", on_projectile_throw)
	EventController.connect("enemy_damaged_event", on_enemy_damaged_event)
	
func handle_new_stats(new_stats_to_add: Dictionary, add_new_stats: bool = true):
	for key in new_stats_to_add.keys():
		if key in stats:
			var stat_label: FittedLabel = hud_texture_rect.get_node_or_null(key + "Label") as Label
			var new_value = check_min_value(key, stats[key], new_stats_to_add[key])
			new_stats_to_add[key] = new_value
			if add_new_stats:
				stats[key] += new_stats_to_add[key]
			if stat_label:
				stat_label.set_text_fit(str(stats[key]))
	handle_new_health_stats(new_stats_to_add)
	handle_new_as_stats(new_stats_to_add)
	Global.luck += new_stats_to_add["luck"]

func check_min_value(stat_name: String, current_value, new_value) -> Variant:
	"""Check if the new value for a stat is below the minimum allowed value.
	If it is, return the difference needed to reach the minimum value."""
	var min_value: Variant = stats_config.get_value(stat_name, "min_value", 0)
	var sum_value = current_value + new_value
	if not min_value:
		return new_value
	if sum_value < min_value:
		return -(current_value - min_value)
	return new_value

func handle_new_health_stats(new_stats_to_add):
	stats["health"] += new_stats_to_add["health_max"]
	handle_health_event()
	
func handle_new_as_stats(new_stats_to_add):
	# Check if attack_speed was modified
	if "attack_speed" in new_stats_to_add:
		# Get the sprite frames for the animation
		var sprite_frames = animation.sprite_frames
		if sprite_frames and sprite_frames.has_animation("attack_1"):
			# Calculate speed scale based on attack_speed
			# For attack_speed=1, we want normal speed (1.0)
			# For attack_speed=2, we want double speed (2.0)
			var speed_scale = stats["attack_speed"] / 1.0
			
			# Set the speed scale for the attack animation
			sprite_frames.set_animation_speed("attack_1", 10 * speed_scale)
			
			# Also update the cooldown timer if it's running
			if not attack_cooldown_timer.is_stopped():
				attack_cooldown_timer.wait_time = 1.0 / stats["attack_speed"]
	
	
func handle_life_steal(damage_amount):
	var regen: int = 0
	if stats["life_steal"] > 0:
		regen = damage_amount / stats["life_steal"]
	stats["health"] += regen
	handle_health_event()

func handle_health_event():
	if stats["health"] > stats["health_max"]:
		stats["health"] = stats["health_max"]
	GameController.health_update(stats["health_max"], stats["health"])

func play_animation(animation_name: String) -> void:
	if not alive:
		return
	animation.play(animation_name)

func death_zoom() -> void:
	var death_zoom_value: Vector2 = Vector2(0.1, 0.1)
	zoom_timer.wait_time = 0.01
	for i in range(40):
		camera.zoom += death_zoom_value
		zoom_timer.start()
		await zoom_timer.timeout

func die():
	death_sound.playing = true
	play_animation("death")
	level_label.queue_free()
	texture_rect.queue_free()
	alive = false
	death_animation_played = true
	await death_zoom()
	print("Gamer_over:" ,game_over.visible)
	await get_tree().create_timer(2).timeout 
	game_over.visible = true
	
func check_health():
	if immortal:
		return
	if stats["health"] <= 0 and not death_animation_played:
		die()

func take_damage(enemyVelocity, knockback_force, damage):
	if not invincible:
		hurt_sound.playing = true
		stats["health"] -= damage
		GameController.health_update(stats["health_max"], stats["health"])
		var kb_direction = (enemyVelocity - velocity).normalized() * knockback_force
		velocity = kb_direction
		move_and_slide()

func enemy_attack(velocity_value, knockback_force, damage):
	if alive and not invincible:
		take_damage(velocity_value, knockback_force, damage)
		play_animation("hurt")
		check_health()
		invincible = true
		invincibility_timer.start()
		hurted_timer.start()
		is_attacking = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * stats["speed"]

func _input(_event):
	if alive:
		if animation.animation == "attack_1" and animation.is_playing():
			return
		
		if Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN):
			play_animation("walk_shadow")
		elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
			play_animation("walk_shadow")
			animation.scale.x = abs(animation.scale.x)
		elif Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
			play_animation("walk_shadow")
			animation.scale.x = -abs(animation.scale.x)
		else:
			play_animation("idle_shadow")

func _physics_process(_delta):
	if alive:
		get_input()
		move_and_slide()
		attack()
		
		var input_direction = Input.get_vector("left", "right", "up", "down")
		if input_direction.x != 0:
			animation.scale.x = sign(input_direction.x) * abs(animation.scale.x)
		
		if animation.animation == "attack_1" and animation.is_playing():
			if animation.frame == 5 and !has_spawned_fireball:
				has_spawned_fireball = true
				spawn_fireball()
		else:
			has_spawned_fireball = false


func _on_invincibility_timeout() -> void:
	invincible = false

func _on_hurted_timeout() -> void:
	if alive:
		animation.stop()
		play_animation("idle_shadow")


func attack():
	if Input.is_action_pressed("attack") and can_attack:
		can_attack = false
		is_attacking = true
		play_animation("attack_1")
		
		# Start attack cooldown based on attack_speed
		attack_cooldown_timer.wait_time = 1.0 / stats["attack_speed"]
		attack_cooldown_timer.start()


func spawn_fireball():
	var main_fireball = fireball_scene.instantiate()
	fireball_sound.playing = true
	get_parent().add_child(main_fireball)

	if animation.scale.x > 0:
		main_fireball.direction = Vector2.RIGHT
		main_fireball.global_position = spawn_projectile_right.global_position
	else:
		main_fireball.direction = Vector2.LEFT
		main_fireball.global_position = spawn_projectile_left.global_position
		main_fireball.rotation_degrees = 180

	main_fireball.rotation_degrees = 0 if main_fireball.direction == Vector2.RIGHT else 180

	var left_fireball = null
	var right_fireball = null
	var up_fireball = null
	var down_fireball = null

	if level >= 1:
		var second_fireball = fireball_scene.instantiate()
		get_parent().add_child(second_fireball)

		second_fireball.direction = main_fireball.direction
		second_fireball.global_position = main_fireball.global_position + Vector2(0, 20)
		second_fireball.rotation_degrees = main_fireball.rotation_degrees
	
	if level >= 5:
		left_fireball = fireball_scene.instantiate()
		right_fireball = fireball_scene.instantiate()
		
		get_parent().add_child(left_fireball)
		get_parent().add_child(right_fireball)

		left_fireball.direction = Vector2.LEFT
		left_fireball.global_position = spawn_projectile_left.global_position
		left_fireball.rotation_degrees = 180

		right_fireball.direction = Vector2.RIGHT
		right_fireball.global_position = spawn_projectile_right.global_position
		right_fireball.rotation_degrees = 0

	if level >= 10:
		up_fireball = fireball_scene.instantiate()
		down_fireball = fireball_scene.instantiate()
		
		get_parent().add_child(up_fireball)
		get_parent().add_child(down_fireball)

		up_fireball.direction = Vector2.UP
		up_fireball.global_position = spawn_projectile_up.global_position
		up_fireball.rotation_degrees = -90

		down_fireball.direction = Vector2.DOWN
		down_fireball.global_position = spawn_projectile_down.global_position
		down_fireball.rotation_degrees = 90

	if level >= 15:
		main_fireball.piercing = true

		if left_fireball:
			left_fireball.piercing = true
		if right_fireball:
			right_fireball.piercing = true
		if up_fireball:
			up_fireball.piercing = true
		if down_fireball:
			down_fireball.piercing = true

	is_attacking = false

func get_frame_count_for_animation(animation_name: String) -> int:
	var sprite_frames = animation.sprite_frames
	if sprite_frames and sprite_frames.has_animation(animation_name):
		return sprite_frames.get_frame_count(animation_name)
	return 0 

func _on_animated_sprite_2d_animation_finished() -> void:
	if animation.animation == "attack_1":
		is_attacking = false
		animation.stop()
		
		var input_direction = Input.get_vector("left", "right", "up", "down")
		if input_direction != Vector2.ZERO:
			play_animation("walk_shadow")
		else:
			play_animation("idle_shadow")

func on_event_xp_collected(value: int) -> void:
	if level < 2:
		stats["experience"] += value * 4
	else:
		stats["experience"] += value
	level = MathXp.calculate_level_from_exp(stats["experience"])
	level_label.text = str(level)
	
func on_projectile_throw(projectile_scene: PackedScene, projectile_direction: Vector2, projectile_position: Vector2, projectile_rotation: int):
	var projectile_instance = projectile_scene.instantiate()
	get_parent().add_child(projectile_instance)
	projectile_instance.direction = projectile_direction
	projectile_instance.global_position = spawn_projectile_right.global_position + projectile_position
	projectile_instance.rotation_degrees = projectile_rotation
	
func on_event_stats_progress(new_stats_to_add: Dictionary) -> void:
	handle_new_stats(new_stats_to_add)
	
func on_enemy_damaged_event(damage_amount, _is_enemy_alive):
	handle_life_steal(damage_amount)

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
