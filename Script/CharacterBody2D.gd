extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 300
var health = 50
var health_max = 50
var health_min = 0
var alive : bool = true
var death_animation_played : bool = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func check_health():
	if health <= 0 and not death_animation_played:
		alive = false
		animation.play("death")
		death_animation_played = true

func _input(event):
	if alive:
		if Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_D):
			animation.play("walk")
			check_health()
		else:
			animation.play("idle")
		
		
			
			
func handleCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		health -= 1
		animation.play("hurt")

func _physics_process(delta):
	if alive:
		handleCollision()
		get_input()
		move_and_slide()
