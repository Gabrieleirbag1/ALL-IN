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
var is_taking_damage: bool = false
var invincible: bool = false
var is_attacking: bool = false #related to attack animation
var can_attack: bool = true #related to (projectile) attack_cooldown

func _ready() -> void:
	Global.player = self
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
			var new_value: Variant = check_min_value(key, stats[key], new_stats_to_add[key])
			new_stats_to_add[key] = new_value
			if add_new_stats:
				stats[key] += new_stats_to_add[key]
			if stat_label:
				stat_label.set_text_fit(str(stats[key]))
	handle_new_health_stats(new_stats_to_add)
	handle_new_as_stats(new_stats_to_add)
	Global.luck += new_stats_to_add["luck"]

func check_min_value(stat_name: String, current_value: Variant, new_value: Variant) -> Variant:
	"""Check if the new value for a stat is below the minimum allowed value.
	If it is, return the difference needed to reach the minimum value."""
	var min_value: Variant = stats_config.get_value(stat_name, "min_value", 0)
	var sum_value: Variant = current_value + new_value
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
	GameController.attack_speed_update(stats["attack_speed"])
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
		var kb_direction = (enemyVelocity - velocity).normalized() * knockback_force
		velocity = kb_direction
		move_and_slide()

func enemy_attack(velocity_value, knockback_force, damage):
	if alive and not invincible:
		is_taking_damage = true
		take_damage(velocity_value, knockback_force, damage)
		play_animation("hurt")
		check_health()
		GameController.health_update(stats["health_max"], stats["health"])
		make_hurt_state()

func make_hurt_state():
	invincible = true
	EventController.emit_signal("player_hit", true)
	hurted_timer.start()
	blinkin_effect()
	is_attacking = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * stats["speed"]

func _input(_event):
	if alive:
		if animation.animation == "attack_1" and animation.is_playing():
			return
		
		if not is_attacking:
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
		if not is_attacking and not is_taking_damage:
			move_and_slide()
		attack()
		
		if not is_attacking:
			var input_direction = Input.get_vector("left", "right", "up", "down")
			if input_direction.x != 0:
				animation.scale.x = sign(input_direction.x) * abs(animation.scale.x) ## 

func blinkin_effect() -> void:
	var blink_times = 5
	var blink_interval = invincibility_timer.wait_time / (blink_times * 2)
	for i in range(blink_times):
		animation.modulate = Color(1, 1, 1, 0.5)
		await get_tree().create_timer(blink_interval).timeout
		animation.modulate = Color(1, 1, 1, 1)
		await get_tree().create_timer(blink_interval).timeout

func _on_invincibility_timeout() -> void:
	invincible = false
	EventController.emit_signal("player_hit", false)
	set_collision_mask_value(3, true)

func _on_hurted_timeout() -> void:
	if alive:
		animation.stop()
		play_animation("idle_shadow")
		is_taking_damage = false
		set_collision_mask_value(3, false)
		invincibility_timer.start()

func attack():
	var mouse_world_pos = get_global_mouse_position()
	var spawn_pos = spawn_projectile_right.global_position if animation.scale.x > 0 else spawn_projectile_left.global_position
	var attack_direction = (mouse_world_pos - spawn_pos).normalized()
	
	# Clamp the angle to max allowed range
	var max_angle = deg_to_rad(45)
	var current_angle = attack_direction.angle()

	if Input.is_action_pressed("attack") and can_attack:
		# if player and mouse position are opposite, turn the player
		if sign(mouse_world_pos.x - global_position.x) != sign(animation.scale.x):
			animation.scale.x = -animation.scale.x

		can_attack = false
		is_attacking = true
		play_animation("attack_1")
			
		# Start attack cooldown based on attack_speed
		attack_cooldown_timer.wait_time = 1.0 / stats["attack_speed"]
		attack_cooldown_timer.start()

	if animation.animation == "attack_1" and animation.is_playing():
		if animation.frame == 5 and !has_spawned_fireball:
			has_spawned_fireball = true
			spawn_fireball(max_angle, current_angle, attack_direction)
	else:
		has_spawned_fireball = false


func spawn_fireball(max_angle, current_angle, attack_direction):
	var main_fireball = fireball_scene.instantiate()
	fireball_sound.playing = true
	get_parent().add_child(main_fireball)	
	# Determine base direction based on player facing
	var base_angle = 0.0 if animation.scale.x > 0 else PI
	
	# Calculate angle difference from base direction
	var angle_diff = current_angle - base_angle
	
	# Normalize angle difference to -PI to PI range
	while angle_diff > PI:
		angle_diff -= 2 * PI
	while angle_diff < -PI:
		angle_diff += 2 * PI
	
	# Clamp the angle difference
	angle_diff = clamp(angle_diff, -max_angle, max_angle)
	
	# Apply clamped angle
	var clamped_angle = base_angle + angle_diff
	attack_direction = Vector2(cos(clamped_angle), sin(clamped_angle))

	main_fireball.piercing = false
	main_fireball.direction = attack_direction

	if animation.scale.x > 0:
		main_fireball.global_position = spawn_projectile_right.global_position
	else:
		main_fireball.global_position = spawn_projectile_left.global_position

	main_fireball.rotation = attack_direction.angle()

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
