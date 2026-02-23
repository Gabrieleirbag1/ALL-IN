class_name Enemy extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent:= $NavigationAgent2D as NavigationAgent2D
@onready var dispawn_timer: Timer = $Dispawn
@onready var attack_timer: Timer = $AttackTimer
@onready var death_sound : Node = $Death
@onready var down_marker_2d: Marker2D = $AttackArea2D/DownMarker2D
@onready var left_marker_2d: Marker2D = $AttackArea2D/LeftMarker2D
@onready var right_marker_2d: Marker2D = $AttackArea2D/RightMarker2D
@onready var up_marker_2d: Marker2D = $AttackArea2D/UpMarker2D
@onready var attack_collision_shape_2d: CollisionShape2D = $AttackArea2D/CollisionShape2D

#no override
var directions: Dictionary
var current_direction: String = "d"
var cancelable_animations: Array[String] = ["idle", "walk", "run"]
var is_hit = false
var player_in_range = false
var is_attacking = false
var current_speed: int = 30
var alive: bool = true
var death_animation_played: bool = false
var immortal: bool = false
var player_chase: bool = false
var player: Player = null
var active: bool = false

#override
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
var ability_attack_damage: int = 5
var ability_attack_cooldown: float = 2.0
var min_ability_attack_frame: int = 6
var max_ability_attack_frame: int = 7

func play_animation(animation_name: String) -> void:
	if not alive:
		return
	animation.play(animation_name + "_" + current_direction)
	
func set_directions() -> void:
	directions = {
		"d": {"marker": down_marker_2d, "rotate": 0}, 
		"l": {"marker": left_marker_2d, "rotate": 90}, 
		"r": {"marker": right_marker_2d, "rotate": -90}, 
		"u": {"marker": up_marker_2d, "rotate": 180}
	}

func _ready() -> void:
	set_directions()
	handle_signals()
	handle_states(false)
	level = MathXp.calculate_level_from_exp(experience)
	play_animation("idle")
	current_speed = speed
	nav_agent.max_speed = 300

func handle_signals():
	EventController.connect("player_hit", on_player_hit)
	
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
		#print("Health :", health, "/", health_max, "/", damage_amount)
		is_hit = true
		play_animation("hurt")
	GameController.enemy_damaged_event(damage_amount, alive)

func die():
	if death_animation_played:
		return
	play_animation("death")
	if death_sound:
		death_sound.playing = true
	alive = false
	death_animation_played = true
	collision_layer = 0
	collision_mask = 0
	nav_agent.avoidance_enabled = false
	dispawn_timer.start()

func get_animation() -> String:
	return animation.animation
	
## @deprecated
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
	var new_velocity = current_agent_pos.direction_to(next_path_pos) * current_speed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	move_and_slide()
	
func move_attack_collision_shape():
	var direction_data = directions[current_direction]
	attack_collision_shape_2d.rotation_degrees = direction_data["rotate"]
	attack_collision_shape_2d.position = direction_data["marker"].position
	

func handle_direction():
	var direction = current_direction
	var velocity_direction = velocity.normalized()
	if abs(velocity_direction.x) > abs(velocity_direction.y):
		current_direction = "r" if velocity_direction.x > 0 else "l"
	else:
		current_direction = "d" if velocity_direction.y > 0 else "u"
	if direction != current_direction:
		var animation_name: String = animation.animation.split("_")[0]
		if animation_name in cancelable_animations:
			move_attack_collision_shape()
			play_animation(animation_name)
	
func handle_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider is Player:
				collider.enemy_attack(velocity, knockback_force, damage)

func handle_navigation():
	if alive:
		chase_player()
		handle_collision()

func handle_states(state: bool):
	visible = state
	set_physics_process(state)
	if state:
		collision_layer = 4
		collision_mask = 7
	
func revive():
	alive = true
	death_animation_played = false
	health = health_max
	nav_agent.avoidance_enabled = true
	handle_states(true)
	if player_chase and animation:
		play_animation("walk")
	else:
		play_animation("idle")
		
func ability_attack():
	is_attacking = true
	player_in_range = true
	current_speed = 0
	play_animation("attack")
	
func clear_animation_state():
	if player_chase:
		play_animation("walk")
		if not visible:
			push_error("not visible")
	else:
		play_animation("idle")

func _physics_process(_delta: float) -> void:
	if not alive:
		return
		
	if not is_hit and not nav_agent.is_navigation_finished():
		handle_navigation()

	if active:
		handle_direction()
		on_ability_attack()
		if not animation.is_playing():
			if animation.animation.begins_with("hurt"): #animation quand ennemi prend des dégâts
				is_hit = false
			elif animation.animation.begins_with("attack"):
				is_attacking = false
				current_speed = speed
			else:
				return
			clear_animation_state()

func on_ability_attack():
	if animation.animation.begins_with("attack"):
		if animation.frame >= min_ability_attack_frame and animation.frame <= max_ability_attack_frame and player_in_range: #frame 6 7
			# Use position-based direction for knockback since velocity is 0 during attack
			var knockback_direction = (player.global_position - global_position).normalized() * speed
			player.enemy_attack(knockback_direction, knockback_force, ability_attack_damage)

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

func _on_attack_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		ability_attack()
		attack_timer.start(ability_attack_cooldown)

func _on_attack_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _on_timer_timeout() -> void:
	makepath()

func _on_dispawn_timeout() -> void:
	GameController.enemy_death(drop_xp, position, enemy_type)
	handle_states(false)
	
func _on_attack_timer_timeout() -> void:
	if player_in_range and not is_attacking:
		ability_attack()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	active = false
	animation.stop()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	active = true
	animation.play()
	
func on_player_hit(is_hit: bool) -> void:
	set_collision_mask_value(1, !is_hit)
