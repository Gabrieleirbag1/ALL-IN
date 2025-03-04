# enemy.gd
extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@export var speed: int = 30
@export var knockback_force: int = 1500
var player_chase: bool = false
var player = null
var health: int = 50
var health_max: int = 50
var health_min: int = 0
var damage: int = 3
var alive: bool = true
var death_animation_played: bool = false
var immortal: bool = false

func play_animation(animation_name: String) -> void:
	if not alive:
		return
	animation.play(animation_name)
	
func manage_collision(collision):
	if collision:
		var collider = collision.get_collider()
		if collider.name == "Player":
			if collider.alive:
				collider.take_damage(velocity, knockback_force, damage)
				collider.animation.play("hurt")
				collider.check_health()

func chase_player(collision):
	if player.position.x < position.x:
		animation.flip_h = true
	else:
		animation.flip_h = false
	manage_collision(collision)

func check_health():
	if immortal:
		return
	if health <= 0 and not death_animation_played:
		alive = false
		play_animation("death")
		death_animation_played = true

func _physics_process(delta: float) -> void:
	if alive:
		check_health()
		if player_chase and player:
			var direction = (player.position - position).normalized()
			velocity = direction * speed * delta
			var collision = move_and_collide(velocity)
			chase_player(collision)
			#rotation = position.angle_to(player.position)
	
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
