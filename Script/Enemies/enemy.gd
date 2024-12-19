extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent:= $NavigationAgent2D as NavigationAgent2D
@onready var dispawn_timer: Timer = $Dispawn

var experience: int = 0
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

func die():
	play_animation("death")
	alive = false
	death_animation_played = true
	dispawn_timer.start()
	
func drop_xp():
	pass
	
func turn_body():
	if player.position.x < position.x:
		animation.flip_h = true
	else:
		animation.flip_h = false

func chase_player():
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
	if nav_agent.is_navigation_finished():
		return
	if player:
		handle_navigation()

func makepath() -> void:
	if player:
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
	queue_free()
	drop_xp()
