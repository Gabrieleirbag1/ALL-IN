extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 30

var player_chase = false
var player = null
var health = 50
var health_max = 50
var health_min = 0
var alive : bool = true
var death_animation_played : bool = false
var immortal = false

func play_animation(animation_name: String) -> void:
	if not alive:
		return
	animation.play(animation_name)
	
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
			var collision = move_and_collide(direction * speed * delta)
			if collision:
				var collider = collision.get_collider()
				if collider.name == "Player":
					if collider.alive:
						collider.health -= 1
						collider.animation.play("hurt")
						collider.check_health()
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
