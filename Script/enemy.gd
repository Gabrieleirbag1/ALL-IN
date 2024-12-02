extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent:= $NavigationAgent2D as NavigationAgent2D

@export var speed: int = 30
@export var knockback_force: int = 1500

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
	play_animation("idle")

func chase_player():
	if player.position.x < position.x:
		animation.flip_h = true
	else:
		animation.flip_h = false
		
	var current_agent_pos = global_position
	var next_path_pos = nav_agent.get_next_path_position()
	var new_velocity = current_agent_pos.direction_to(next_path_pos) * speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	move_and_slide()

func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	if player:
		chase_player()

func makepath() -> void:
	if player:
		nav_agent.target_position = player.global_position
		
func _on_timer_timeout() -> void:
	makepath()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		player_chase = true
		play_animation("walk")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false
		play_animation("idle")

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
