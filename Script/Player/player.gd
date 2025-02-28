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

@export var damage: int = 10
@export var attack_spped: int = 10
@export var life_steel: int = 10
@export var critical: int = 10
@export var health: int = 50
@export var health_max: int = 50
@export var health_min: int = 0
@export var speed: int = 250
@export var experience: int = 0
@export var luck: int = 10 

var level: int = 1
var alive : bool = true
var death_animation_played : bool = false
var immortal: bool = false
var invincible: bool = false
var is_attacking: bool = false
var can_attack: bool = true

func _ready() -> void:
	EventController.connect("xp_collected", on_event_xp_collected)
	EventController.connect("stats_progress", on_event_stats_progress)
	level = MathXp.calculate_level_from_exp(experience)
	level_label.text = str(level)
	game_over.visible = false

func on_event_xp_collected(value: int) -> void:
	if level < 2:
		experience += value * 4
	else:
		experience += value
	level = MathXp.calculate_level_from_exp(experience)
	level_label.text = str(level)

func on_event_stats_progress(stats: Dictionary) -> void:
	print(stats)
	damage += stats["damage"]
	attack_spped += stats["attack_speed"]
	life_steel += stats["life_steel"]
	critical += stats["critical"]
	health_max += stats["health"]
	speed += stats["speed"]
	luck += stats["luck"]

func play_animation(animation_name: String) -> void:
	if not alive:
		return
	animation.play(animation_name)

func death_zoom() -> void:
	var death_zoom = Vector2(0.1, 0.1)
	zoom_timer.wait_time = 0.01
	for i in range(40):
		camera.zoom += death_zoom
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
	if health <= 0 and not death_animation_played:
		die()

func take_damage(enemyVelocity, knockback_force, damage):
	if not invincible:
		hurt_sound.playing = true
		health -= damage
		var kb_direction = (enemyVelocity - velocity).normalized() * knockback_force
		velocity = kb_direction
		move_and_slide()

func enemy_attack(velocity, knockback_force, damage):
	if alive and not invincible:
		take_damage(velocity, knockback_force, damage)
		play_animation("hurt")
		check_health()
		invincible = true
		invincibility_timer.start()
		hurted_timer.start()
		is_attacking = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _input(event):
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

func _physics_process(delta):
	if alive:
		get_input()
		move_and_slide()
		attack()
		print(get_frame_count_for_animation("attack_1"))
		
		var input_direction = Input.get_vector("left", "right", "up", "down")
		if input_direction.x != 0:
			animation.scale.x = sign(input_direction.x) * abs(animation.scale.x)


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
		await get_tree().create_timer(0.5).timeout 
		can_attack = true


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
