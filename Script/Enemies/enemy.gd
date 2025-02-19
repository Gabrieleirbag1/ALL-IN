class_name Enemy extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent:= $NavigationAgent2D as NavigationAgent2D
@onready var dispawn_timer: Timer = $Dispawn

var enemy_type: String = ""
var experience: int = 0
var drop_xp: int = 100
var level: int = 1
var knockback_force: int = 1500
var speed: int = 30
var health: int = 50
var health_max: int = 50
var health_min: int = 0
var damage: int = 3
var alive: bool = true
var death_animation_played: bool = false
var immortal: bool = false
var player_chase: bool = false
var player = null


func play_animation(animation_name: String) -> void:
	if not alive:
		return
	animation.play(animation_name)

func _ready() -> void:
	level = MathXp.calculate_level_from_exp(experience)
	play_animation("idle")
	nav_agent.max_speed = 300

func take_damage(damage_amount: int):
	if not alive or immortal:
		return

	if damage_amount <= 0:
		play_animation("walk")
		return

	health -= damage_amount
	if health <= 0:
		die()
	else:
		# print("Health :", health, "/", health_max )
		play_animation("hurt")

func die():
	if death_animation_played:
		return
	play_animation("death")
	alive = false
	death_animation_played = true
	set_collision_mask_value(1, false)
	dispawn_timer.start()


func get_animation() -> String:
	return animation.animation
	
	
func turn_body():
	if player && is_instance_valid(player):
		if player.position.x < position.x:
			animation.flip_h = true
		else:
			animation.flip_h = false

func chase_player():
	if !player || !is_instance_valid(player):
		return
	
	var current_agent_pos = global_position
	var next_path_pos = nav_agent.get_next_path_position()
	var new_velocity = current_agent_pos.direction_to(next_path_pos) * speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	move_and_slide()

func handle_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider.name == "Player":
				collider.enemy_attack(velocity, knockback_force, damage)

func handle_navigation():
	if alive:
		turn_body()
		chase_player()
		handle_collision()

func _physics_process(delta: float) -> void:
	if not alive:
		return
	
	if not nav_agent.is_navigation_finished():
		handle_navigation()
	
	if animation.animation == "hurt" and not animation.is_playing():
		if player_chase:
			play_animation("walk")
		else:
			play_animation("idle")

func makepath() -> void:
	if player && is_instance_valid(player):
		nav_agent.target_position = player.global_position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player_chase = true
		play_animation("walk")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		player_chase = false
		play_animation("idle")

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _on_timer_timeout() -> void:
	makepath()

func _on_dispawn_timeout() -> void:
	GameController.enemy_death(drop_xp, position, enemy_type)
	queue_free()
